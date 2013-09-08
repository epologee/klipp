module Template

  class Token
    attr_accessor :hidden, :value
    attr_accessor :comment, :validation, :validation_hint
    attr_reader :name

    def initialize(name)
      @name = name
      @hidden = false
    end

  end

end