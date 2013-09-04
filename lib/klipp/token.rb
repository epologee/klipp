require 'yaml'

module Klipp

  class Token
    attr_accessor :value
    attr_reader :title, :subtitle, :default, :validate, :not_valid_response

    def initialize(token_yml)
      if token_yml.is_a? String
        parsed = YAML.load token_yml
      else
        parsed = token_yml
      end

      @title = parsed['title']
      @subtitle = parsed['subtitle']
      @default = parsed['default']
      @validate = parsed['validate']
      @not_valid_response = parsed['not_valid_response']

    rescue Exception => e
      p token_yml
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