require 'formatador'
require 'colorize'
require 'project'
require 'klipp/configuration'
require 'klipp/version'
require 'klipp/parameter_list'
require 'template/spec'
require 'template/token'

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
    0 # exit code
  rescue Exception => e
    Formatador.display_line("[red][!] #{e.message}[/]")
    1 # exit code
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