module Template

  class Spec
    require 'date'

    attr_accessor :identifier, :block_actions_under_git
    attr_reader :post_actions, :required_files

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
      @required_files = Array.new

      self[:BLANK] = Template::Token.new('', true)
      self[:DATE] = Template::Token.new(DateTime.now.strftime('%F'), true)
      self[:YEAR] = Template::Token.new(DateTime.now.strftime('%Y'), true)
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

    def pre_action=(action)
      pre_actions << action
    end

    def pre_actions
      @pre_actions ||= []
    end

    def pre_actions=(pre_actions)
      @pre_actions = pre_actions.is_a?(Array) ? pre_actions : [pre_actions.to_s]
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

    def set_token_values(tokens, verbose=false)
      token_errors = Hash[]
      puts() if verbose
      tokens.each do |name, value|
        token = self[name]
        begin
          if token
            Formatador.display_line("#{name}: [bold]#{value}[/]") if verbose
            token.value = value
          else
            token_errors[name] = "unknown token :#{name}"
          end
        rescue Exception => e
          token_errors[name] = "token :#{name}. #{e.message}"
        end
      end

      @tokens.each do |name, token|
        token_errors[name] = "missing value for token :#{name}" if token.value == nil && token_errors[name] == nil
      end

      if token_errors.length > 0
        msg = "Token configuration error:\n\n\t"
        msg << token_errors.map { |name, error_message| error_message }.join("\n\t")
        invalidate msg
      end

      puts() if verbose
    end

    def confirm_required_files()
      missing_files = Array.new
      self.required_files.each do |required_file|
        file_path = File.join(required_file.directory, required_file.name)
        missing_files << required_file unless File.exists? file_path
      end

      if missing_files.length > 0
        message = "Required file#{missing_files.length > 1 ? 's' : ''} not found:\n\n"
        missing_files.each do |missing_file|
          file_path = File.join(missing_file.directory, missing_file.name)
          message << "\t#{file_path} - #{missing_file.comment ? "#{missing_file.comment}" : ''}\n"
        end
        raise message
      end
    end

    def invalidate(message)
      raise message
    end

    def each
      @tokens.each { |name, token| yield(name, token) }
    end

    def required_file name, &config
      required_file = Template::RequiredFile.new name
      raise 'Incomplete file configuration' unless block_given?
      config.yield(required_file)
      @required_files << required_file
    end

    def klippfile
      kf = "create '#{self.class.expand_identifier(self.identifier)}' do |tokens|\n\n"
      @tokens.each do |name, token|
        unless token.hidden
          kf += "  # #{token.comment}\n" if token.comment
          kf += "  # #{token.validation_hint}\n" if token.validation_hint
          if token.type == :bool
            kf += "  tokens[:#{name}] = #{token.default_value ? 'true' : 'false'}\n"
          else
            kf += "  tokens[:#{name}] = \"#{token.default_value}\"\n"
          end
          kf += "\n"
        end
      end
      kf += "end"
    end

    def klippspec
      ks = "spec '#{identifier}' do |s|\n"
      ks += "  s.block_actions_under_git = true\n"
      ks += "  # s.pre_actions = ['echo \"Hello klipp!\"']\n"
      ks += "  # s.post_actions = ['pod install']\n"
      ks += "\n"
      ks += "  s.token :REPLACEABLE do |t|\n"
      ks += "    t.comment = \"Replaceable value (to insert in any filename or string containing 'XXREPLACEABLEXX')\"\n"
      ks += "    t.validation = /^[A-Z][A-Za-z0-9 ]{2,}$/\n"
      ks += "    t.validation_hint = 'At least three characters long, start with a capital character, may contain spaces'\n"
      ks += "  end\n"
      ks += "\n"
      ks += "  s.token :TOGGLE do |t|\n"
      ks += "    t.comment = \"Toggle value (to insert in any filename or string containing 'XXTOGGLEXX')\"\n"
      ks += "    t.type = :bool\n"
      ks += "    # t.bool_strings = ['NO','YES']\n"
      ks += "  end\n"
      ks += "\n"
      ks += "  # ...\n"
      ks += "\n"
      ks += "end"
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
          begin
            IO.write target_file, replace_tokens(File.read(source_file))
          rescue
            FileUtils.cp(source_file, target_file)
          end
        end
      else
        raise "#{target_file} already exists, not overwriting. Use -f to force overwriting."
      end

      target_file
    end

    def replace_tokens(string_with_tokens, delimiter='XX')
      unless string_with_tokens.valid_encoding?
        raise "Invalid string encoding #{string_with_tokens.encoding}"
      end

      replaced = string_with_tokens
      @tokens.each do |name, token|
        needle = delimiter+name.to_s+delimiter
        replacement = token.to_s
        replaced.gsub!(needle, replacement)
      end
      replaced
    end
  end

end