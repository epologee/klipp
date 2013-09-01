require 'klipp/buffered_output'

module Klipp

  class Command

    class Project
      extend BufferedOutput::ClassMethods
      include BufferedOutput::InstanceMethods

      def initialize(arguments)
        #hier was je gebleven
      end

      def run

      end

    end

  end

end