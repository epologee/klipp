module Project

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    case command
      when 'init'
        cli_init(*params)
      when nil
        raise 'Missing project command'
      else
        raise "Unknown project command: #{command}"
    end
  end

  def self.cli_init(params)

  end

end