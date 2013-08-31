require 'yaml'

module Klipp

  class Template

    def initialize path, name
      full_path = File.join(path, "#{name}.yml")
      raise "Template not found at #{full_path}" unless File.exists? full_path
    end

  end

end
