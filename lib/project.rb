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

    Formatador.display_line("[green][√] #{will_overwrite ? "Re-saved" : "Saved"} #{filename}.[/]")

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
    spec_path = Template::Spec.spec_path_for_identifier maker.identifier
    spec = Template::Spec.from_file spec_path
    spec.set_token_values(maker.tokens, params.splice_option('-v'))

    block_actions = spec.block_actions_under_git && git_repository?
    if spec.pre_actions.count > 0
      if block_actions
        Formatador.display_line("[yellow][i][/] Git repository found, not running pre-actions (see .klippspec).")
        puts()
      else
        run_actions(spec.pre_actions) if Klipp.env.prod?
        Formatador.display_line("[green][√] Pre-actions complete.[/]")
      end
    end

    force = params.splice_option('-f')

    source_dir = File.dirname(Template::Spec.spec_path_for_identifier maker.identifier)
    target_dir = Dir.pwd

    source_files = Dir.glob(File.join(source_dir, '**', '*'), File::FNM_DOTMATCH).reject { |f| f == spec_path }

    result = source_files.map do |source_file|
      spec.transfer_file source_file, spec.target_file(source_dir, source_file, target_dir), force
    end

    verbose = params.splice_option '-v'

    Formatador.display_line("[green][√] Project made from template #{Template::Spec.expand_identifier maker.identifier}. #{'Run `klipp project make -v` to see what files were created.' unless verbose}[/]")

    if (verbose)
      puts()
      strip = File.dirname(Dir.pwd)+File::SEPARATOR
      result.each { |r| Formatador.display_line(r.gsub(strip, '')) unless File.directory? r }
    end

    if spec.post_actions.count > 0
      if block_actions
        puts()
        Formatador.display_line("[yellow][i][/] Git repository found, not running post-actions (see .klippspec).")
      else
        run_actions(spec.post_actions) if Klipp.env.prod?
        Formatador.display_line("[green][√] Post-actions complete.[/]")
      end
    end

    puts()
    Formatador.display_line("[green][√] Done.[/]")
  end

  def self.git_repository?
    `git rev-parse --is-inside-work-tree 2>&1`.match /true/
  end

  def self.run_actions(actions)
    count = actions.count()
    puts()
    actions.each do |action|
      Formatador.display_line("[yellow][i][/] Running `#{action}`...")
      puts()
      system(action) if Klipp.env.prod?
      puts()
      #IO.popen(action, :err=>[:child, :out]) { |f| puts '  '+f.read.gsub("\n", "\n  ") }
      raise "Error running action `#{action}`." if $? && $?.exitstatus > 0
    end
  end

end