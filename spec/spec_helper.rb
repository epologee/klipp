if ENV['CI'] || ENV['GENERATE_COVERAGE']
  require 'simplecov'
  require 'coveralls'
  SimpleCov.start

  if ENV['CI']
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  elsif ENV['GENERATE_COVERAGE']
    SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  end

end

#Dir.glob('lib/**/*.rb').each do |file|
#  required = require file
#  p "required: #{required} file: #{file}"
#end

require 'klipp'

#if Dir.glob('lib/**/*.rb').map { |f| p f; require "./#{f}"}.include? false
#  raise 'error loading files'
#end

def read_fixture fixture_name
  File.read(File.join(__dir__, 'fixtures', fixture_name))
end
