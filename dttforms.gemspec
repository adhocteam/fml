# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dttforms/version'

Gem::Specification.new do |spec|
  spec.name          = "dttforms"
  spec.version       = DTTForms::VERSION
  spec.authors       = ["Bill Mill"]
  spec.email         = ["bill.mill@gmail.com"]
  spec.summary       = %q{Read FML and create forms}
  spec.description   = %q{Read FML and create forms}
  spec.homepage      = "http://adhocteam.us"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "haml"
end
