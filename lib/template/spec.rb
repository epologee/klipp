module Template

  class Spec
    attr_accessor :name

    def initialize &config
      @tokens = Hash[]
      raise 'Spec configuration requires a block parameter' unless block_given?
      defaults
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
      raise "Redeclaring tokens not allowed: #{name}" if @tokens[name]
      @tokens[name] = token
    end

    def defaults
      blank = self[:BLANK] = Template::Token.new :BLANK
      blank.hidden = true
      blank.value = ''

      date = self[:DATE] = Template::Token.new :DATE
      date.hidden = true
      date.value = DateTime.now.strftime('%F')

      year = self[:YEAR] = Template::Token.new :YEAR
      year.hidden = true
      year.value = DateTime.now.strftime('%Y')
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