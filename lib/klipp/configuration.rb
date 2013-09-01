module Klipp

  class Configuration
    @@auto_create_dirs = false # set by the gem's binary

    def self.auto_create_dirs
      @@auto_create_dirs
    end

    def self.auto_create_dirs= auto_create_dirs
      @@auto_create_dirs = auto_create_dirs
    end

    def self.auto_create(dir)
      if auto_create_dirs && File.directory?(File.dirname dir) && !File.exists?(dir)
        Dir.mkdir dir
      end
      dir
    end

    @@root = nil

    def self.root_dir
      auto_create(@@root || File.join(Dir.home, '.klipp'))
    end

    def self.root_dir=(root)
      @@root = root
    end

    def self.templates_dir
      auto_create File.join(root_dir, 'templates')
    end

    def initialize
      raise "Root directory not found: #{self.class.root_dir} (auto create #{self.class.auto_create_dirs ? 'enabled' : 'disabled'})" unless File.directory? self.class.root_dir
    end

  end

end