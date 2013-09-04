require 'ptools'
require 'fileutils'

module Klipp

  class Project

    def initialize(template)
      @template = template
    end

    def create
      # Check template directory exists
      # Copy all files while adjusting paths
      source_template_dir = File.join(Klipp::Configuration.templates_dir, @template.name)
      target_template_dir = File.join(Dir.pwd, @template.name)

      raise "Target directory already exists. Klipp will not overwrite your project: #{target_template_dir}" if File.exists? target_template_dir

      @source_files = Dir.glob(File.join(source_template_dir, '**', '*'))
      @source_files.each do |source_file|
        transfer_file source_file, target_file(source_template_dir, source_file, target_template_dir)
      end
    end

    def target_file(source_template_dir, source_file, target_template_dir)
      stripped_path = source_file.gsub(source_template_dir, '')
      customizable_path = @template.replace_tokens(stripped_path)
      File.join(target_template_dir, customizable_path)
    end

    def transfer_file(source_file, target_file)
      FileUtils.mkdir_p File.dirname(target_file)

      if File.directory? source_file
        FileUtils.mkdir_p target_file
      elsif File.binary? source_file
        FileUtils.cp(source_file, target_file)
      else
        IO.write target_file, @template.replace_tokens(File.read(source_file))
      end
    end

  end

end