require 'project/maker'

module Project

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    commands = {
        init: lambda { cli_init(params) },
        make: lambda { cli_make }
    }
    case command
      when nil
        raise Klipp::Hint.new "Add a command to `klipp project [#{commands.keys.join('|')}]`"
      else
        if commands[command.to_sym]
          commands[command.to_sym].call
        else
          raise "Unknown project command: #{command}"
        end
    end
  end

  def self.cli_init(params=[])
    params = Klipp::ParameterList.new(params)
    template = params.shift_argument
    raise Klipp::Hint.new("Add a template name to `klipp project init [template]`. Use `klipp template list` to see your options.") unless template

    spec = Template::Spec.from_file Template::Spec.spec_path_for_identifier(template)
    filename = 'Klippfile'

    force = params.splice_option('-f')
    will_overwrite = File.exists?(filename) && force

    raise "#{filename} already exists, not overwriting. Use -f to force overwriting" if File.exists?(filename) && !force

    File.write('Klippfile', spec.klippfile)

    Formatador.display_line("[green][√] #{will_overwrite ? "Re-saved" : "Saved"} #{filename}[/]")

    capture_stdout {
      `open -a TextMate #{filename} 2>&1` if File.exists?(filename)
    }

    if $? && $?.exitstatus > 0
      `open -t #{filename}` if File.exists?(filename)
    end
  end

  def self.cli_make
    Project::Maker.new().make
  end

end