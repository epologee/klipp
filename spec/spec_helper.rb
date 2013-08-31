require 'simplecov'
require 'coveralls'
SimpleCov.start

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

require 'klipp'

def read_fixture fixture_name
  File.read(File.join(__dir__, 'fixtures', fixture_name))
end
