require 'yaml'

class Token
  attr_reader :token

  def initialize token_yml
    parsed = YAML.load token_yml
    @token = parsed['token']
  end

end