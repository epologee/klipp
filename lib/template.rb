require 'template/spec'
require 'template/token'

module Template

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    case command
      when 'list'
        cli_list(params)
      when nil
        raise 'Missing template command'
      else
        raise "Unknown template command: #{command}"
    end
  end

  def self.cli_list(params=[])
    list.each do |template|
      Formatador.display_line "  * [green]#{template[:name].ljust(16)}[/] (#{template[:repo]})"
    end
  end

  def self.list
    specs = Dir.glob(File.join(Klipp::Configuration.root_dir, '**', '*.klippspec'))
    specs.map do |spec|
      relative_spec = spec.gsub(Klipp::Configuration.root_dir, '')
      {
          name: File.basename(spec, '.klippspec'),
          repo: relative_spec.split(File::SEPARATOR).map {|x| x=="" ? File::SEPARATOR : x}[1..-1].first
      }
    end
  end

end