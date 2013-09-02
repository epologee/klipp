module Klipp

  class Command

    class Project
      extend BufferedOutput::ClassMethods
      include BufferedOutput::InstanceMethods

      def initialize(arguments)
        @params = ParameterList.new(arguments)
      end

      def self.banner
        sub_commands = ['list']
        banner = "To see help for the available sub commands run:\n\n"
        banner + sub_commands.map { |cmd| "  * #{('klipp project '+cmd).green} --help" }.join("\n")
      end

      def self.options
        [
            ['--help', 'Show help information'],
        ]
      end

      def run
        sub_command_argument = @params.shift_argument
        case sub_command_argument
          when 'list'
            list
          when 'create' || 'new'
            create
          else
            raise Klipp::Command::Help.new(self.class, @params, sub_command_argument)
        end
      end

      def list
        template_files = Dir.glob File.join(Klipp::Configuration.templates_dir, '*.yml')
        template_files.each do |file|
          buffer_puts("+ #{File.basename(file, '.*').green}")
        end
      end

      def create
        # match template name with existing template

      end

    end

  end

end