require 'coveralls'
Coveralls.wear!

if Dir.glob('lib/**/*.rb').map { |f| require "./#{f}" }.include? false
  raise 'error loading files' 
end

def read_fixture fixture_name
  IO.readlines(File.join(__dir__, 'fixtures', fixture_name))
end