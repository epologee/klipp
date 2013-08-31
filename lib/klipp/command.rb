module Klipp

  class Command

    class ARGV < Array
      def options;        select { |x| x.to_s[0,1] == '-' };   end
      def arguments;      self - options;                      end
      def option(name);   !!delete(name);                      end
      def shift_argument; (arg = arguments[0]) && delete(arg); end
    end

    def self.run(*argv)
      sub_command = parse(*argv)
      sub_command.run

      #rescue Interrupt
      #  puts "[!] Cancelled".red
      #  #Config.instance.verbose? ? raise : exit(1)
      #  exit(1)
      #
      #rescue Exception => e
      #  puts e.message
      #  unless e.is_a?(Informative) || e.is_a?(Help)
      #    puts *e.backtrace
      #  end
      #  exit 1
    end

  end

  def self.parse(*argv)
    argv = ARGV.new(argv)
    if argv.option('--version')
      puts VERSION
      exit!(0)
    end

    #show_help = argv.option('--help')
    #
    #String.send(:define_method, :colorize) { |string, _| string } if argv.option('--no-color')
    #
    #command_class = case command_argument = argv.shift_argument
    #                  when 'project' then
    #                    TargetDiff
    #                  when 'project-diff' then
    #                    ProjectDiff
    #                  when 'show' then
    #                    Show
    #                end
    #
    #if command_class.nil?
    #  raise Help.new(self, argv, command_argument)
    #elsif show_help
    #  raise Help.new(command_class, argv)
    #else
    #  command_class.new(argv)
    #end
  end


end

