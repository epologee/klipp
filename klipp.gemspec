# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'klipp/version'

Gem::Specification.new do |spec|
  spec.name          = 'klipp'
  spec.version       = Klipp::VERSION
  spec.authors       = ['Eric-Paul Lecluse']
  spec.email         = %w(e@epologee.com)
  spec.description   = 'Klipp, Xcode templates for the rest of us.'
  spec.summary       = "Klipp is a command line gem for creating new (Xcode) projects from existing templates. Unlike Apple's private plist-based templating system, Klipp takes an existing Xcode project and creates a new project by copying and modifying an existing template project by your own specifications."
  spec.homepage      = 'https://github.com/epologee/klipp'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/).map
  #do |f|
  #  f unless f.include?('spec/fixtures') || f.include?("_spec.rb")
  #end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'bundler', '~> 1.3'
  spec.add_runtime_dependency 'rake', '~> 10.1'
  spec.add_runtime_dependency 'ptools', '~> 1.2'
  spec.add_runtime_dependency 'formatador', '~> 0.2'
  spec.add_runtime_dependency 'colorize', '~> 0.6'
  spec.add_runtime_dependency 'grit', '~> 2.5'
  spec.add_runtime_dependency 'highline', '~> 1.6'
  spec.add_runtime_dependency 'zaru', '~> 0'
end
