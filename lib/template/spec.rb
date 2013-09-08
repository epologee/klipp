module Template

  class Spec
    require 'date'

    attr_accessor :identifier, :post_action

    def self.spec_path_for_identifier(identifier)
      chunks = identifier.split(File::SEPARATOR)
      name = chunks.pop
      repo = chunks.count > 0 ? File.join(chunks.pop, '**') : '**'
      specs = Dir.glob(File.join(Klipp::Configuration.root_dir, repo, "#{name}.klippspec"))
      raise "Unknown template: #{identifier}. Use `klipp template list` to see your options" unless specs && specs.count > 0
      raise "Found multiple templates named #{identifier}. Prefix the template with the repository to narrow it down. Use `klipp template list` to see your options" if specs && specs.count > 1
      specs.first
    end

    def self.hash_for_spec_path(spec_path)
      relative_spec = spec_path.gsub(Klipp::Configuration.root_dir, '')
      {
          name: File.basename(spec_path, '.klippspec'),
          repo: relative_spec.split(File::SEPARATOR).map { |x| x=="" ? File::SEPARATOR : x }[1..-1].first
      }
    end

    def self.hash_to_identifier(template_hash)
      "#{template_hash[:repo]}/#{template_hash[:name]}"
    end

    def self.from_file(path)
      string = IO.read path
      spec = Template::Spec.new
      spec.from_string(string, path)
    end

    def initialize
      @tokens = Hash[]

      blank = self[:BLANK] = Template::Token.new
      blank.hidden = true
      blank.value = ''

      date = self[:DATE] = Template::Token.new
      date.hidden = true
      date.value = DateTime.now.strftime('%F')

      year = self[:YEAR] = Template::Token.new
      year.hidden = true
      year.value = DateTime.now.strftime('%Y')
    end

    def from_string(string, path)
      begin
        eval(string, nil, path)
      rescue Exception => e
        raise "Error evaluating spec: #{File.basename(path)}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      end
      validate
    end

    # This method is called from the klippspec
    def spec identifier, &config
      self.identifier = identifier
      begin
        config.yield(self) if (block_given?)
      rescue Exception => e
        raise "Invalid klippspec configuration: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      end
      validate
    end

    def token identifier, &config
      token = Template::Token.new
      raise 'Incomplete token configuration' unless block_given?
      config.yield(token)
      self[identifier] = token
    end

    def [](name)
      @tokens[name]
    end

    def []=(name, token)
      raise "Redeclaring tokens not allowed: #{name}" if @tokens[name]
      @tokens[name] = token
    end

    def validate
      msg = 'Template configuration invalid: '
      invalidate msg+'missing name' unless @identifier && @identifier.length > 0
      self
    end

    def invalidate(message)
      raise message
    end

    def klippfile
      kf = "template '#{self.identifier}' do |project|\n\n"
      @tokens.each do |name, token|
        unless token.hidden
          kf += "  # #{token.comment}\n" if token.comment
          kf += "  # #{token.validation_hint}\n" if token.validation_hint
          kf += "  project[:#{name}] = \"\"\n"
          kf += "\n"
        end
      end
      kf += "end"
    end
  end

end