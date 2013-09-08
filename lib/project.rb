module Project

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    case command
      when 'init'
        cli_init(params)
      when nil
        raise 'Missing project command'
      else
        raise "Unknown project command: #{command}"
    end
  end

  def self.cli_init(params=[])
    params = Klipp::ParameterList.new(params)
    template = params.shift_argument
    raise 'Template name required for project init' unless template

    spec = Template::Spec.from_file(Template.path_for_template template)
    File.write('Klippfile', spec.klippfile)
  end

end