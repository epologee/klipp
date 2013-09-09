module Template

  class Token
    attr_accessor :hidden, :value
    attr_accessor :comment, :validation, :validation_hint

    def initialize
      @hidden = false
    end

    def value=(value)
      raise "Invalid value '#{value}'. #{validation_hint}" unless validation.match(value) if validation
      @value = value
    end

  end

end