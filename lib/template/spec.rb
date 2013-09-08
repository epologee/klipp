module Template

  class Spec
    attr_accessor :name, :post_action

    def self.from_file(path)
      string = IO.read path if File.exists? path
      from_string(string, path)
    end

    def self.from_string(string, path)
      begin
        eval(string, nil, path)
      rescue Exception => e
        raise "Invalid #{File.basename(path)}:\n#{e.backtrace.join("\n")}"
      end
    end

    def initialize &config
      @tokens = Hash[]
      raise 'Spec configuration requires a block parameter' unless block_given?
      defaults
      config.yield(self)
      validate
    end

    def token identifier, &config
      token = Template::Token.new
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
      blank = self[:BLANK] = Template::Token.new
      blank.hidden = true
      blank.value = ''

      date = self[:DATE] = Template::Token.new
      date.hidden = true
      date.value = DateTime.now.strftime('%F')

      year = self[:YEAR] = Template::Token.new
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

    def klippfile
      kf = "template '#{self.name}' do |project|\n\n"
      @tokens.each do |name, token|
        unless token.hidden
          kf += "  # #{token.comment}\n" if token.comment
          kf += "  # #{token.validation_hint}\n" if token.validation_hint
          kf += "  project[:#{name}] = \"\"\n"
          kf += "\n"
        end
      end
      kf += "end"
    end
  end

end