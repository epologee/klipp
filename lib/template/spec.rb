module Template

  class Spec
    attr_accessor :name

    def initialize &config
      @tokens = Hash[]
      raise 'Spec configuration requires a block parameter' unless block_given?
      config.yield(self)
      validate
    end

    def token identifier, &config
      token = Template::Token.new(identifier)
      raise 'Incomplete token configuration' unless block_given?
      config.yield(token)
      self[identifier] = token
    end

    def [](name)
      @tokens[name]
    end

    def []=(name, token)
      @tokens[name] = token
    end

    def validate

    end
  end

end