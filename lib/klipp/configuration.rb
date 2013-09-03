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

    def self.root_dir
      auto_create File.join(Dir.home, '.klipp')
    end

    def self.templates_dir
      auto_create File.join(root_dir, 'templates')
    end

  end

end