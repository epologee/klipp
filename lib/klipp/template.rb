require 'yaml'
require 'erb'

module Klipp

  class Template
    attr_reader :tokens

    def initialize path, name
      @name = name
      full_path = File.join(path, "#{name}.yml")
      raise "Template not found at #{full_path}" unless File.exists? full_path
      yaml_tokens = YAML.load ERB.new(File.read(full_path)).result
      @tokens = yaml_tokens.map { |yaml_token| Klipp::Token.new(yaml_token) }
    end

    def load_klippfile(klippfile)
      yaml = YAML.load ERB.new(File.read(klippfile)).result

      tokens = @tokens.dup
      yaml.each do |name, value|
        matching_token = tokens.detect { |t| t.name == name }
        raise "Unknown token found named #{name}" unless matching_token
        matching_token.value = value
        tokens.delete(matching_token)
      end

      raise "No values found for tokens: #{tokens.map{|t|t.name}}" if tokens.length > 0
    end

    def value_for_token(name)
      @tokens.detect { |t| t.name == name }.value
    end

    def klippfile
      "#{@name}.klippfile"
    end

    def generated_klippfile
      @tokens.map { |t| "#{t.name}:\n# #{t.subtitle}"}.join("\n\n")
    end

  end

end
