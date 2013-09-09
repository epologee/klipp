require 'template/spec'
require 'template/token'

module Template

  def self.route(*argv)
    params = Klipp::ParameterList.new(argv)
    command = params.shift_argument
    commands = {
        list: lambda { cli_list },
        init: lambda { cli_init(params) }
    }
    case command
      when nil
        raise Klipp::Hint.new "Add a command to `klipp template [#{commands.keys.join('|')}]`"
      else
        if commands[command.to_sym]
          commands[command.to_sym].call
        else
          raise "Unknown command `klipp template #{command}`"
        end
    end
  end

  def self.cli_list
    l = list
    l.each do |template|
      Formatador.display_line "* #{template[:repo]}/[green]#{template[:name].ljust(16)}[/]"
    end

    Formatador.display_line "You can use just the name in commands `#{l.first[:name]}`, as long as it's unambiguous."
    Formatador.display_line "Otherwise include the repository, e.g. `#{l.first[:repo]+'/'+l.first[:name]}`"
  end

  def self.list
    specs = Dir.glob(File.join(Klipp::Configuration.root_dir, '**', '*.klippspec'))
    specs.map do |spec|
      Template::Spec.hash_for_spec_path spec
    end
  end

  def self.cli_init(params)
    params = Klipp::ParameterList.new(params)
    identifier = params.shift_argument
    raise Klipp::Hint.new("Add a new template name, like `klipp template init AwesomeTemplate`") unless identifier && identifier.length > 0
    raise "Invalid template name `#{identifier}`. Stick to simple characters and spaces." unless identifier.match(/^[ A-Za-z0-9_-]+$/)

    spec = Template::Spec.new
    spec.identifier = identifier.strip
    file = File.join(Dir.pwd, "#{spec.identifier}.klippspec")
    force = params.splice_option('-f')

    file_existed = File.exists?(file)
    allow_write = force || !file_existed

    File.write(file, spec.klippspec) if allow_write
  end

end