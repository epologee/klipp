require 'simplecov'
require 'coveralls'
require 'mocha/api'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require 'klipp'

def fixture_path fixture_name
  Dir.glob(File.join(__dir__, 'fixtures', '**', fixture_name)).first
end

def read_fixture fixture_name
  File.read(fixture_path fixture_name)
end

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.order = 'random'
end