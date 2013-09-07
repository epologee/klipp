module Template

  class Spec
    attr_accessor :name

    def initialize &config
      @tokens = Hash[]
      raise 'Spec configuration requires a block parameter' unless block_given?
      config.yield(self)
      (self['BLANK'] = Template::Token.new('BLANK')).hidden = true

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
      msg = 'Template configuration invalid: '
      invalidate msg+'missing name' unless @name && @name.length
    end

    def invalidate(message)
      raise message
    end
  end

end