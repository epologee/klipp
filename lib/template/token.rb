class String
  def matches_true?
    Regexp.new('y|yes|true', Regexp::IGNORECASE).match(self)
  end

  def matches_false?
    Regexp.new('n|no|false', Regexp::IGNORECASE).match(self)
  end
end

module Template
  class Token
    attr_accessor :hidden, :value, :default_value, :type, :bool_strings
    attr_accessor :comment, :validation, :validation_hint

    def initialize(value = nil, hidden = false)
      self.value = value unless value.nil?
      @hidden = hidden
    end

    def type=(type)
      allowed_types = [:string, :bool]
      raise "Invalid type '#{type}'. Allowed types are: #{allowed_types.join(', ')}" unless allowed_types.include?(type)
      @type = type
    end

    def type
      @type || :string
    end

    def value
      return false if @value === false
      @value || self.default_value
    end

    def value=(value)
      if (self.type == :bool) && value.is_a?(String)
        value = if value.matches_true?
                  true
                elsif value.matches_false?
                  false
                end
      end
      raise "Invalid value '#{value.to_s}'. #{validation_hint}" unless validate?(value)
      @value = value
    end

    def default_value
      @default_value || (self.type == :string ? '' : false)
    end

    def bool_strings
      @bool_strings ? @bool_strings : %w(NO YES)
    end

    def validation
      self.type == :bool ? Regexp.new('([yn])|yes|no', Regexp::IGNORECASE) : @validation
    end

    def validation_hint
      case
      when self.type == :string then
        @validation_hint || (validation ? "Match /#{validation.to_s}/ (no custom validation_hint given)." : "Text required")
      when self.type == :bool then
        "Boolean value, either 'true' or 'false' (but without the apostrophes)"
      end
    end

    def validate?(value)
      case
      when self.type == :string then
        value.is_a?(String) && (validation.nil? || validation.match(value))
      when self.type == :bool then
        value.is_a?(TrueClass) or value.is_a?(FalseClass)
      end
    end

    def to_s
      case
      when self.type == :bool then
        bool_strings[value ? 1 : 0]
      else
        value
      end
    end
  end
end
