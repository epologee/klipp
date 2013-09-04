require 'klipp/buffered_output'
require 'klipp/version'
require 'klipp/configuration'
require 'klipp/token'
require 'klipp/template'
require 'klipp/parameter_list'
require 'klipp/project'
require 'colorize'

module Klipp
  extend BufferedOutput::ClassMethods

  def self.display_exception exception
    if exception.is_a? HelpRequest
      help = exception
    else
      help = HelpRequest.new exception.message, true
      help.set_backtrace(exception.backtrace)
    end

    buffer_puts help.message
    exit help.exit_status
  end

  def self.route(*argv)
    @params = Klipp::ParameterList.new(argv)
    command = @params.shift_argument
    case command
      when 'version'
        version
      when 'list'
        list
      when 'prepare'
        prepare @params.first
      when 'create'
        create @params.first
      when nil
        raise HelpRequest.new('Use one of the commands below to start with klipp.', false, true)
      else
        raise "Unknown command: #{command}"
    end

  rescue Exception => e
    display_exception e
  end

  def self.version
    buffer_puts Klipp::VERSION
  end

  def self.list
    files = template_files

    raise "No templates found. Create a template directory and .yml file in #{Klipp::Configuration.templates_dir}" unless files.length > 0

    buffer_puts("Available templates for use with #{'klipp prepare'.yellow} or #{'klipp create'.yellow}:\n\n")
    files.each do |file|
      buffer_puts("  * #{File.basename(file, '.*').green}")
    end
  end

  def self.prepare(template_name)
    raise HelpRequest.new 'Add a template name to the `prepare` command.' unless template_name

    template = Klipp::Template.new(Klipp::Configuration.templates_dir, template_name)
    raise "#{template.klippfile} already exists. Delete it if you want to prepare a new template." if File.exists? template.klippfile
    IO.write(template.klippfile, template.generated_klippfile)
  end

  def self.create(template_name)
    if template_name
      klippfile = File.join(Dir.pwd, "#{template_name}.klippfile")
    else
      klippfile = Dir.glob(File.join(Dir.pwd, '*.klippfile')).first
      template_name = File.basename(klippfile, File.extname(klippfile)) if klippfile
    end

    template = Klipp::Template.new(Klipp::Configuration.templates_dir, template_name)

    if klippfile
      # load token values from klippfile
      template.load_klippfile klippfile
    elsif template_name
      # ask for token values with highline
      raise "Direct user input not yet supported. Use #{'klipp prepare'.yellow} to prepare a .klippfile"
    else
      raise "Add a template name to the `create` command, or use #{'klipp prepare'.yellow} to prepare a .klippfile"
    end

    project = Klipp::Project.new(template)
    project.create
  end

  private

  def self.template_files
    Dir.glob File.join(Klipp::Configuration.templates_dir, '*.yml')
  end

end

class HelpRequest < StandardError
  def initialize(msg, unknown=false, show_title=false)
    @unknown = unknown
    @show_title = show_title
    super(msg)
  end

  def message
    if @unknown
      "[!] #{super.to_s}".red+"\n\n#{commands}\n\n#{self.backtrace.join("\n")}"
    else
      "#{@show_title ? title+"\n\n" : ''}"+"[?] #{super.to_s}".yellow+"\n\n#{commands}"
    end
  end

  def title
    "\033[1mKlipp\033[22m, Xcode templates for the rest of us. Version: #{Klipp::VERSION}"
  end

  def commands
    commands = [
        version: 'Display the Klipp version number.',
        list: "List all available klipp templates in #{Klipp::Configuration.templates_dir}",
        prepare: 'Prepare a .klippfile to edit in your favorite text editor.',
        create: 'Create a project based on the template name or .klippfile in the current directory'
    ]
    command_list = commands.map { |cmd| cmd.map { |key, summary| "  * klipp #{key.to_s.ljust(10).green} #{summary}" } }.join("\n")
    "Commands:\n\n#{command_list}"
  end

  def exit_status
    @unknown ? 2 : 1
  end
end