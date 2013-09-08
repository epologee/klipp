module Project

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    commands = {
        init: lambda { cli_init(params) }
    }
    case command
      when nil
        raise Klipp::Hint.new "Add a command to $ klipp project [#{commands.keys.join('|')}]"
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
    raise 'Template name required for project init' unless template

    spec = Template::Spec.from_file Template.path_for_template(template)
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

end