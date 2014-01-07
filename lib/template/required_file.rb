require 'zaru'

module Template

  class RequiredFile
    attr_accessor :name, :directory # :default_value, :type, :bool_strings
    attr_accessor :comment # , :validation, :validation_hint

    def initialize(name)
      raise 'File name required' unless name.length > 0
      raise "Invalid characters found in file name (try #{Zaru.sanitize!(name)})" unless Zaru.sanitize!(name) == name
      self.name = name if name
      self.directory = '.'
    end
  end
end
