# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'asciitracker/version'

Gem::Specification.new do |spec|
  spec.name          = "asciitracker"
  spec.version       = AsciiTracker::VERSION
  spec.authors       = ["dirk lu\xCC\x88sebrink"]
  spec.email         = ["dirk.luesebrink@gmail.com"]
  spec.description   = %q{
    keeping track of time in a textfile. now web app, no mouse clicking. No GUI
    is as easy as "12:13-17:34", and no time tracker i know of allows you to
    add interrupts like: '0:13 pause: phone call with mum'
  }
  spec.summary       = %q{time tracking the ascii way}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "applix"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'guard-rspec'

  if RUBY_PLATFORM.match /java/i
    spec.add_development_dependency 'ruby-debug'
  else
    spec.add_development_dependency 'debugger'
  end
end