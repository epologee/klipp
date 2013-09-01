require 'yaml'

module Klipp

  class Template
    attr_reader :tokens

    def initialize path, name
      full_path = File.join(path, "#{name}.yml")
      raise "Template not found at #{full_path}" unless File.exists? full_path
      yaml_tokens = YAML.load_file full_path
      @tokens = yaml_tokens.map { |yaml_token| Klipp::Token.new(yaml_token) }
    end

  end

end
