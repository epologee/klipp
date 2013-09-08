require 'template/spec'
require 'template/token'

module Template

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    commands = {
        list: lambda {  cli_list(params) }
    }
    case command
      when nil
        raise Klipp::Hint.new "Add a command to $ klipp [#{commands.keys.join('|')}]"
      else
        if commands[command.to_sym]
          commands[command.to_sym].call
        else
          raise "Unknown klipp command: #{command}"
        end
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

  def self.path_for_template(template)
    specs = Dir.glob(File.join(Klipp::Configuration.root_dir, '**', "#{template}.klippspec"))
    specs.first if specs && specs.count
  end

end