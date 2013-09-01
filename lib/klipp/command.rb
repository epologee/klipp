require 'colored'
require 'klipp/buffered_output'

module Klipp

  class Command
    extend BufferedOutput

    autoload :Project, 'klipp/command/project'

    class Version < StandardError
      def message
        Klipp::VERSION
      end
    end

    class Help < StandardError
      def initialize(command_class, argv, unrecognized_command = nil)
        @command_class, @argv, @unrecognized_command = command_class, argv, unrecognized_command
      end

      def message
        message = [
            '',
            'Options:',
            '',
            options,
            "\n",
        ].join("\n")
        message << "[!] Unrecognized command: `#{@unrecognized_command}'\n".red if @unrecognized_command
        message << "[!] Unrecognized argument#{@argv.count > 1 ? 's' : ''}: `#{@argv.join(' - ')}'\n".red unless @argv.empty?
        message
      end

      private

      def options
        options = @command_class.options
        keys = options.map(&:first)
        key_size = keys.inject(0) { |size, key| key.size > size ? key.size : size }
        options.map { |key, desc| "    #{key.ljust(key_size)}   #{desc}" }.join("\n")
      end
    end

    def self.banner
      commands = ['project']
      banner = "To see help for the available commands run:\n\n"
      banner + commands.map { |cmd| "  * $ klipp #{cmd.green} --help" }.join("\n")
    end

    def self.options
      [
          ['--help', 'Show help information'],
          ['--version', 'Prints the version of Klipp'],
      ]
    end

    class ARGS < Array
      def options
        select { |x| x.to_s[0, 1] == '-' }
      end

      def arguments
        self - options
      end

      def splice_option(name)
        !!delete(name)
      end

      def shift_argument
        (arg = arguments[0]) && delete(arg)
      end
    end

    def self.parse(*argv)
      command_line_arguments = ARGS.new(argv)

      raise Version.new if command_line_arguments.splice_option('--version')

      command_line_arguments.splice_option('--help')

      String.send(:define_method, :colorize) { |string, _| string } if command_line_arguments.splice_option('--no-color')

      command_argument = command_line_arguments.shift_argument

      command_class = case command_argument
                        when 'project' then
                          Project
                        else
                          raise Help.new(self, command_line_arguments, command_argument)
                      end

      command_class.new(command_line_arguments)
    end

    def self.run(*argv)
      sub_command = self.parse(*argv)
      sub_command.run

        #rescue Interrupt
        #  self.output.puts "[!] Cancelled".red
        #  exit(1)

    rescue Exception => e
      output.puts e.message
      unless e.is_a?(Help) || e.is_a?(Version)
        output.puts *e.backtrace
      end
      exit 1
    end

  end

end

