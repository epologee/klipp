module Klipp

  class Command

    class Project
      extend BufferedOutput::ClassMethods
      include BufferedOutput::InstanceMethods

      @@file_output = nil

      def self.file_output=(file_output)
        @@file_output = file_output
      end

      def self.file_output
        @@file_output
      end

      def initialize(arguments)
        @params = ParameterList.new(arguments)
      end

      def self.banner
        sub_commands = %w(list prepare)
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
          when 'prepare'
            prepare
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

      def prepare
        template_name = @params.shift_argument
        raise Klipp::Command::Help.new(self.class, @params) unless template_name

        template = Klipp::Template.new(Klipp::Configuration.templates_dir, template_name)
        target_file = self.class.file_output || template.klippfile
        raise "Klippfile already exists: #{template.klippfile}" if File.exists? target_file
        File.open(target_file, 'w') { |f| f.write(template.generated_klippfile) }
      end

    end

  end

end