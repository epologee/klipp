# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'klipp/version'

Gem::Specification.new do |spec|
  spec.name          = "klipp"
  spec.version       = Klipp::VERSION
  spec.authors       = ["Eric-Paul Lecluse"]
  spec.email         = ["e@epologee.com"]
  spec.description   = "New projects."
  spec.summary       = "New projects with style."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "highline"
  spec.add_development_dependency "ptools"
end
