require 'simplecov'
require 'coveralls'
require 'mocha/api'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require 'klipp'

def read_fixture fixture_name
  matches = Dir.glob File.join(__dir__, 'fixtures', '**', fixture_name)
  File.read(matches.first)
end

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.order = 'random'
end