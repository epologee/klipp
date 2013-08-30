require 'coveralls'
Coveralls.wear!

if Dir.glob('lib/**/*.rb').map { |f| require "./#{f}" }.include? false
  raise 'error loading files' 
end