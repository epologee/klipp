module Klipp

  class Creator
    attr_reader :identifier, :tokens

    def self.from_file(path)
      raise "Klippfile not found in directory #{File.dirname path}. Run `klipp prepare`." unless File.exists? path
      string = IO.read path
      creator = Klipp::Creator.new
      creator.eval_string(string, path)
    end

    def self.from_user_input(template_identifier, highline)
      creator = Klipp::Creator.new
      creator.ask_user_input(template_identifier, highline)
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

    def ask_user_input(identifier, highline = HighLine.new)
      @identifier = identifier
      spec_path = Template::Spec.spec_path_for_identifier(identifier)
      template = Template::Spec.from_file(spec_path)
      template.each do |name, token|
        self.tokens[name] = highline.ask("#{token.comment}?") { |q|
          q.validate = token.validation if token.validation
          q.responses[:not_valid] = token.validation_hint if token.validation_hint
        } unless token.hidden
      end
      validate
    end

    def validate
      msg = 'Klippfile invalid: '
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

    def create(template_identifier, &config)
      @identifier = template_identifier
      config.yield(@tokens) if block_given?
    end
  end

end