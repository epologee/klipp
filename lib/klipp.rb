require 'formatador'
require 'colorize'
require 'project'
require 'template'
require 'klipp/configuration'
require 'klipp/version'
require 'klipp/parameter_list'

module Klipp

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument;
    commands = {
        project: lambda { Project.route(*params) },
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
      else
        Formatador.display_line("[red][!] #{e.message}[/]")
    end
    1 # exit code
  end

  class Hint < StandardError
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