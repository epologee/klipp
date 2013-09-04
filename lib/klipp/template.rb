require 'yaml'
require 'erb'

module Klipp

  class Template
    attr_reader :tokens, :name

    def initialize path, name
      @name = name
      raise 'Attempted to initialize template without name' unless name

      full_path = File.join(path, "#{name}.yml")
      raise "Unknown template name: #{name} (in template directory #{path})" unless File.exists?(full_path)
      yaml_tokens = YAML.load(File.read(full_path))

      @tokens = Hash[yaml_tokens.map { |token_name, values| [token_name, Klipp::Token.new(values)] }]
    end

    def [](name)
      @tokens[name].value
    end

    def []=(name, value)
      @tokens[name].value=value
    end

    def load_klippfile(klippfile)
      yaml = YAML.load(File.read(klippfile))
      raise 'Tokens not matching' unless yaml.keys == @tokens.keys
      yaml.each { |name, value| self[name] = value }
    end

    def klippfile
      "#{@name}.klippfile"
    end

    def generated_klippfile
      @tokens.map { |name, t| "#{name}:\n# #{t.subtitle}" }.join("\n\n")
    end

    def replace_tokens(string_with_tokens, delimiter='XX')
      replaced = string_with_tokens
      @tokens.each { |name, t| replaced.gsub!(delimiter+name+delimiter, t.value || '') }
      replaced
    end

  end

end
