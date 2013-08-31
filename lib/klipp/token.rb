require 'yaml'

module Klipp
  class Token
    attr_reader :token, :title, :subtitle, :default, :validate, :not_valid_response, :value

    def initialize(token_yml)
      parsed = YAML.load token_yml
      @token = parsed['token']
      @title = parsed['title']
      @subtitle = parsed['subtitle']
      @default = parsed['default']
      @validate = parsed['validate']
      @not_valid_response = parsed['not_valid_response']
    end

    def ask_for_input(terminal = nil)
      @value = (terminal || HighLine.new).ask("\n<%= color('#{@title}', BOLD) %> #{"(#{@subtitle})" if @subtitle})?") do |q|
        q.default = @default if @default
        q.validate = @validate if @validate
        q.responses[:not_valid] = @not_valid_response if @not_valid_response
      end
    end

  end
end