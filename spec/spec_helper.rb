require 'simplecov'
require 'coveralls'
require 'mocha/api'

SimpleCov.start
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require 'klipp'

def read_fixture fixture_name
  File.read(File.join(__dir__, 'fixtures', fixture_name))
end

RSpec.configure do |config|
  config.mock_framework = :mocha
  config.order = 'random'
end

def capture_stdout
  old_stdout = $stdout
  new_stdout = StringIO.new
  $stdout = new_stdout
  yield
  $stdout = old_stdout
  new_stdout.string
end