module Project

  class Maker
    attr_reader :identifier, :tokens

    def self.from_file(path)
      string = IO.read path
      maker = Project::Maker.new
      maker.eval_string(string, path)
    end

    def initialize
      @tokens = Hash.new
    end

    def eval_string(string, path)
      begin
        eval(string, nil, path)
      rescue Exception => e
        raise "Error evaluating klippfile: #{File.basename(path)}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      end
      validate
    end

    def validate
      msg = 'Project klippfile invalid: '
      invalidate msg+'missing name' unless @identifier && @identifier.length > 0
      matching_specs = Template::Spec.specs_matching_identifier(@identifier)

      case
        when matching_specs.count == 0
          msg += "Unknown template name `#{@identifier}`. "
          msg += "Run `klipp template list` to see your options."
          invalidate msg+msg
        when matching_specs.count > 1
          msg += "Found multiple templates named `#{@identifier}`. "
          msg += "Use a full template identifier to pick one. "
          msg += "Run `klipp template list` to see your options."
          hint msg+msg
        else
          self
      end
    end

    def invalidate(message)
      raise message
    end

    def hint(message)
      raise Klipp::Hint.new(message)
    end

    def instantiate(template_identifier, &config)
      @identifier = template_identifier
      config.yield @tokens if block_given?
    end
  end

end