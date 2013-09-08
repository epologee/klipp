module Template

  class Token
    attr_accessor :hidden, :value
    attr_accessor :comment, :validation, :validation_hint

    def initialize
      @hidden = false
    end

  end

end