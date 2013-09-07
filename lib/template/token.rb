module Template

  class Token
    attr_accessor :hidden
    attr_reader :name

    def initialize(name)
      @name = name
      @hidden = false
    end

  end

end