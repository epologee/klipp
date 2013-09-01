module BufferedOutput
  module ClassMethods
    @@output = nil

    def output=(output)
      @@output = output
    end

    def output
      @@output || $stdout
    end

    def buffer_puts(output)
      self.output.puts output
    end
  end

  module InstanceMethods
    def buffer_puts(output)
      self.class.output.puts output
    end
  end
end
