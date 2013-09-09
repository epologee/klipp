require 'project/maker'

module Project

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    commands = {
        init: lambda { cli_init(params) },
        make: lambda { cli_make(params) }
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

    raise "#{filename} already exists, not overwriting. Use -f to force overwriting." if File.exists?(filename) && !force

    File.write('Klippfile', spec.klippfile)

    Formatador.display_line("[green][√] #{will_overwrite ? "Re-saved" : "Saved"} #{filename}[/]")

    capture_stdout {
      `open -a TextMate #{filename} 2>&1` if File.exists?(filename)
    }

    if $? && $?.exitstatus > 0
      `open -t #{filename}` if File.exists?(filename)
    end
  end

  def self.cli_make(params)
    params = Klipp::ParameterList.new(params)
    maker = Project::Maker.from_file File.join(Dir.pwd, 'Klippfile')
    spec = Template::Spec.from_file(Template::Spec.spec_path_for_identifier maker.identifier)
    spec.set_token_values(maker.tokens)
    force = params.splice_option('-f')

    source_dir = File.dirname(Template::Spec.spec_path_for_identifier maker.identifier)
    target_dir = Dir.pwd

    @source_files = Dir.glob(File.join(source_dir, '**', '*'), File::FNM_DOTMATCH)
    @source_files.each do |source_file|
      spec.transfer_file source_file, spec.target_file(source_dir, source_file, target_dir), force
    end
  end

end