require 'klipp/version'
require 'klipp/template'
require 'klipp/token'
require 'klipp/command'
require 'klipp/configuration'
require 'klipp/parameter_list'

module Klipp
  extend BufferedOutput::ClassMethods

  def self.display_exception exception
    if exception.is_a? HelpRequest
      help = exception
    else
      help = HelpRequest.new exception.message, true
    end

    buffer_puts help.message
    exit help.exit_status
  end

  def self.route(*argv)
    @params = Klipp::ParameterList.new(argv)
    command = @params.shift_argument
    case command
      when 'prepare'
        prepare @params.first
      when 'list'
        list
      when nil
        raise HelpRequest.new('Use one of the commands below to start with klipp.', false, true)
      else
        raise "Unknown command: #{command}"
    end

  rescue Exception => e
    display_exception e
  end

  def self.list
    buffer_puts("Available templates:\n\n")
    template_files = Dir.glob File.join(Klipp::Configuration.templates_dir, '*.yml')
    template_files.each do |file|
      buffer_puts("  + #{File.basename(file, '.*').green}")
    end
  end

  def self.prepare(template_name)
    raise HelpRequest.new 'Add a template name to the `prepare` command.' unless template_name

    template = Klipp::Template.new(Klipp::Configuration.templates_dir, template_name)
    raise "#{template.klippfile} already exists. Delete it if you want to prepare a new template." if File.exists? template.klippfile
    IO.write(template.klippfile, template.generated_klippfile)
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
      "[!] #{super.to_s}".red+"\n\n#{commands}"
    elsif super.to_s.length
      "#{@show_title ? title+"\n\n" : ''}"+"[?] #{super.to_s}".yellow+"\n\n#{commands}"
    else
      "#{@show_title ? title+"\n\n" : ''}#{commands}"
    end
  end

  def title
    "\033[1mKlipp\033[22m, Xcode templates for the rest of us."
  end

  def commands
    commands = [
        list: 'List all available klipp templates.',
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