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
        raise Klipp::Hint.new "Add a command to `klipp template [#{commands.keys.join('|')}]`"
      else
        if commands[command.to_sym]
          commands[command.to_sym].call
        else
          raise "Unknown command `klipp template #{command}`"
        end
    end
  end

  def self.cli_list(params=[])
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
      relative_spec = spec.gsub(Klipp::Configuration.root_dir, '')
      {
          name: File.basename(spec, '.klippspec'),
          repo: relative_spec.split(File::SEPARATOR).map {|x| x=="" ? File::SEPARATOR : x}[1..-1].first
      }
    end
  end

  def self.path_for_template(template)
    chunks = template.split(File::SEPARATOR)
    name = chunks.pop
    repo = chunks.count > 0 ? File.join(chunks.pop, '**') : '**'
    specs = Dir.glob(File.join(Klipp::Configuration.root_dir, repo, "#{name}.klippspec"))
    raise "Unknown template: #{template}. Use `klipp template list` to see your options" unless specs && specs.count > 0
    raise "Found multiple templates named #{template}. Prefix the template with the repository to narrow it down. Use `klipp template list` to see your options" if specs && specs.count > 1
    specs.first
  end

end