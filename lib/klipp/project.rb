module Klipp

  class Project

    def initialize(template)
      @template = template
    end

    def create
      # Check template directory exists
      # Copy all files while adjusting paths
      templates_path = File.join(Klipp::Configuration.templates_dir, @template.name)

      @source_files = Dir.glob(File.join(templates_path, '**', '*'))

      target_path = File.join(Dir.pwd, @template.name)

      @file_map = @source_files.map do |file|
        # strip template_path from file path
        # feed file to template and get it replaced
        # add template_path to replaced path
        customizable_path = @template.replace_tokens(file.gsub(templates_path, ''))
        {
            source: file,
            target: File.join(target_path, customizable_path)
        }
      end

      puts @file_map.join("\n")
    end

    private

    def target_path_for_file(templates_path, file)

    end

  end

end