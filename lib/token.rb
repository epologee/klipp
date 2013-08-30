require 'yaml'

class Token
  attr_reader :token, :title, :subtitle, :default, :validate, :not_valid_response

  def initialize token_yml
    parsed = YAML.load token_yml
    @token = parsed['token']
    @title = parsed['title']
    @subtitle = parsed['subtitle']
    @default = parsed['default']
    @validate = parsed['validate']
    @not_valid_response = parsed['not_valid_response']
  end

end