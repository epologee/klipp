require 'ptools'
require 'formatador'
require 'colorize'
require 'fileutils'
require 'grit'
require 'highline/import'

require 'template'
require 'klipp/configuration'
require 'klipp/version'
require 'klipp/parameter_list'
require 'klipp/creator'

module Klipp

  class Hint < StandardError
  end

  class ClusterError < StandardError
    attr_accessor :messages
  end

  def self.env
    @@env ||= StringInquirer.new('prod')
  end

  def self.env=(env)
    @@env = env
  end

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument;
    commands = {
        prepare: lambda { cli_prepare(params) },
        create: lambda { cli_create(params) },
        template: lambda { Template.route(*params) }
    }
    case command
      when nil
        raise Klipp::Hint.new "Add a command to `klipp [#{commands.keys.join('|')}]`"
      else
        if commands[command.to_sym]
          commands[command.to_sym].call
        else
          raise "Unknown command `klipp #{command}`"
        end
    end
    0 # exit code
  rescue Exception => e
    case e
      when Klipp::Hint
        Formatador.display_line("[yellow][?] #{e.message}[/]")
      when Klipp::ClusterError
        e.messages.each { |msg| Formatador.display_line("[red][!] #{msg}[/]\n") }
      else
        Formatador.display_line("[red][!] #{e.message}[/]\n")
        Formatador.display_line(e.backtrace.first)
    end
    1 # exit code
  end

  def self.cli_prepare(params=[])
    params = Klipp::ParameterList.new(params)
    template = params.shift_argument
    raise Klipp::Hint.new("Add a template name to `klipp prepare [template]`. Use `klipp template list` to see your options.") unless template

    spec = Template::Spec.from_file Template::Spec.spec_path_for_identifier(template)
    filename = 'Klippfile'

    force = params.splice_option('-f')
    will_overwrite = File.exists?(filename) && force

    raise "#{filename} already exists, not overwriting. Use -f to force overwriting." if File.exists?(filename) && !force

    File.write('Klippfile', spec.klippfile)

    Formatador.display_line("[green][√] Prepared #{filename} #{'again' if will_overwrite}.[/]")

    capture_stdout {
      `open -a TextMate #{filename} 2>&1` if File.exists?(filename)
    }

    if $? && $?.exitstatus > 0
      `open -t #{filename}` if File.exists?(filename)
    end
  end

  def self.cli_create(params, highline = nil)
    params = Klipp::ParameterList.new(params)
    if (interactive_identifier = params.shift_argument)
      creator = Klipp::Creator.from_user_input(interactive_identifier, highline)
      puts()
    else
      creator = Klipp::Creator.from_file File.join(Dir.pwd, 'Klippfile')
    end
    spec_path = Template::Spec.spec_path_for_identifier creator.identifier
    spec = Template::Spec.from_file spec_path

    validation_errors = Array.new

    begin
      spec.set_token_values(creator.tokens, params.splice_option('-v'))
    rescue Exception => e
      validation_errors << e.message
    end

    begin
      spec.confirm_required_files
    rescue Exception => e
      validation_errors << e.message
    end

    if validation_errors.length > 0
      e = Klipp::ClusterError.new
      e.messages = validation_errors
      raise e
    end

    block_actions = spec.block_actions_under_git && git_repository?
    if spec.pre_actions.count > 0
      if block_actions
        Formatador.display_line("[yellow][i][/] Git repository found, not running pre-actions (see .klippspec).")
        puts()
      else
        run_actions(spec.pre_actions) if Klipp.env.prod?
        Formatador.display_line("[green][√] Pre-actions complete.[/]")
        puts()
      end
    end

    force = params.splice_option('-f')

    source_dir = File.dirname(Template::Spec.spec_path_for_identifier creator.identifier)
    target_dir = Dir.pwd

    source_files = Dir.glob(File.join(source_dir, '**', '*'), File::FNM_DOTMATCH).reject { |f| f == spec_path }

    result = source_files.map do |source_file|
      spec.transfer_file source_file, spec.target_file(source_dir, source_file, target_dir), force
    end

    verbose = params.splice_option '-v'

    Formatador.display_line("[green][√] Creation completed using template #{Template::Spec.expand_identifier creator.identifier}. #{'Run `klipp create -v` to see what files were created.' unless verbose}[/]")
    puts()

    if (verbose)
      strip = File.dirname(Dir.pwd)+File::SEPARATOR
      result.each { |r| Formatador.display_line(r.gsub(strip, '')) unless File.directory? r }
      puts()
    end

    if spec.post_actions.count > 0
      if block_actions
        Formatador.display_line("[yellow][i][/] Git repository found, not running post-actions (see .klippspec).")
        puts()
      else
        run_actions(spec.post_actions) if Klipp.env.prod?
        Formatador.display_line("[green][√] Post-actions complete.[/]")
        puts()
      end
    end

    Formatador.display_line("[green][√] Done.[/]")
  end

  def self.git_repository?
    `git rev-parse --is-inside-work-tree 2>&1`.match /true/
  end

  def self.run_actions(actions)
    count = actions.count()
    puts()
    actions.each do |action|
      Formatador.display_line("[yellow][i][/] Running `#{action}`...")
      puts()
      system(action) if Klipp.env.prod?
      puts()
      #IO.popen(action, :err=>[:child, :out]) { |f| puts '  '+f.read.gsub("\n", "\n  ") }
      raise "Error running action `#{action}`." if $? && $?.exitstatus > 0
    end
  end
end

class StringInquirer < String
  def method_missing(method_name, *arguments)
    if method_name.to_s[-1, 1] == '?'
      self == method_name.to_s[0..-2]
    else
      super
    end
  end
end

def capture_stdout
  old_stdout = STDOUT.clone
  pipe_r, pipe_w = IO.pipe
  pipe_r.sync = true
  output = ''
  reader = Thread.new do
    begin
      loop do
        output << pipe_r.readpartial(1024)
      end
    rescue EOFError
    end
  end
  STDOUT.reopen pipe_w
  yield
ensure
  STDOUT.reopen old_stdout
  pipe_w.close
  reader.join
  return output
end