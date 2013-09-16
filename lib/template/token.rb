module Template

  class Token
    attr_accessor :hidden, :value, :type, :bool_strings
    attr_accessor :comment, :validation, :validation_hint

    def initialize(value = nil, hidden = false)
      self.value = value if value
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

    def value=(value)
      raise "Invalid value '#{value.to_s}'. #{validation_hint}" unless validate?(value)
      @value = value
    end

    def bool_strings
      %w(NO YES)
    end

    def validation_hint
      case
        when self.type == :string then
          @validation_hint || (validation ? "Match /#{validation.to_s}/ (no custom validation_hint given)." : "Text required")
        when self.type == :bool then
          "Boolean value, either `true` or `false` (no quotes)"
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