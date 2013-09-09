module Template

  class Spec
    require 'date'

    attr_accessor :identifier
    attr_reader :post_actions

    def self.identifier_is_ambiguous(identifier)
      specs_matching_identifier(identifier).count == 1
    end

    def self.specs_matching_identifier(identifier)
      chunks = identifier.split(File::SEPARATOR)
      name = chunks.pop
      repo = chunks.count > 0 ? File.join(chunks.pop, '**') : '**'
      Dir.glob(File.join(Klipp::Configuration.root_dir, repo, "#{name}.klippspec"))
    end

    def self.spec_path_for_identifier(identifier)
      specs = specs_matching_identifier identifier
      raise "Unknown template: #{identifier}. Use `klipp template list` to see your options" unless specs && specs.count > 0
      raise "Found multiple templates named #{identifier}, use a full template identifier to pick one. Run `klipp template list` to see your options" if specs && specs.count > 1
      specs.first
    end

    def self.hash_for_spec_path(spec_path)
      relative_spec = spec_path.gsub(Klipp::Configuration.root_dir, '')
      {
          name: File.basename(spec_path, '.klippspec'),
          repo: relative_spec.split(File::SEPARATOR).map { |x| x=="" ? File::SEPARATOR : x }[1..-1].first
      }
    end

    def self.hash_to_identifier(template_hash)
      "#{template_hash[:repo]}/#{template_hash[:name]}"
    end

    def self.expand_identifier(template_identifier)
      path = spec_path_for_identifier template_identifier
      hash = hash_for_spec_path path
      hash_to_identifier hash
    end

    def self.from_file(path)
      string = IO.read path
      spec = Template::Spec.new
      spec.from_string(string, path)
    end

    def initialize
      @tokens = Hash[]

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

    def post_action=(action)
      post_actions << action
    end

    def post_actions
      @post_actions ||= []
    end

    def post_actions=(post_actions)
      @post_actions = post_actions.is_a?(Array) ? post_actions : [post_actions.to_s]
    end

    def from_string(string, path)
      begin
        eval(string, nil, path)
      rescue Exception => e
        raise "Error evaluating spec: #{File.basename(path)}: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      end
      validate_spec
    end

    # This method is called from the klippspec
    def spec identifier, &config
      self.identifier = identifier
      begin
        config.yield(self) if (block_given?)
      rescue Exception => e
        raise "Invalid klippspec configuration: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      end
      validate_spec
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

    def validate_spec
      msg = 'Template configuration invalid: '
      invalidate msg+'missing name' unless @identifier && @identifier.length > 0
      self
    end

    def set_token_values(tokens)
      msg = 'Token configuration error: '
      tokens.each do |name, value|
        token = self[name]
        invalidate msg+"unknown token :#{name}" unless token
        begin
          token.value = value
        rescue Exception => e
          invalidate msg+"token :#{name}. #{e.message}"
        end
      end
      @tokens.each do |name, token|
        invalidate msg+"missing value for token :#{name}" if token.value == nil
      end
    end

    def invalidate(message)
      raise message
    end

    def klippfile
      kf = "instantiate '#{self.class.expand_identifier(self.identifier)}' do |tokens|\n\n"
      @tokens.each do |name, token|
        unless token.hidden
          kf += "  # #{token.comment}\n" if token.comment
          kf += "  # #{token.validation_hint}\n" if token.validation_hint
          kf += "  tokens[:#{name}] = \"\"\n"
          kf += "\n"
        end
      end
      kf += "end"
    end

    def target_file(source_dir, source_file, target_dir)
      stripped_path = source_file.gsub(source_dir, '')
      customizable_path = replace_tokens(stripped_path)
      File.join(target_dir, customizable_path)
    end

    def transfer_file(source_file, target_file, overwrite)
      FileUtils.mkdir_p File.dirname(target_file)

      if File.directory? source_file
        FileUtils.mkdir_p target_file
      elsif !File.exists?(target_file) || overwrite
        if File.binary? source_file
          FileUtils.cp(source_file, target_file)
        else
          IO.write target_file, replace_tokens(File.read(source_file))
        end
      else
        raise "#{target_file} already exists, not overwriting. Use -f to force overwriting."
      end

      target_file
    end

    def replace_tokens(string_with_tokens, delimiter='XX')
      replaced = string_with_tokens
      @tokens.each { |name, token| replaced.gsub!(delimiter+name.to_s+delimiter, token.value) }
      replaced
    end

  end

end