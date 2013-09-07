require 'formatador'
require 'colorize'
require 'project'
require 'klipp/version'
require 'klipp/parameter_list'

module Klipp

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument;
    case (command)
      when 'project'
        Project.route(*params)
      when nil
        raise 'Missing klipp command'
      else
        raise "Unknown command: #{command}"
    end

    0
  rescue Exception => e
    Formatador.display_line("[red][!] #{e.message}[/]")
    1
  end

end