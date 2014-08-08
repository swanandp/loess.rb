# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loess/version'

Gem::Specification.new do |spec|
  spec.name          = "loess"
  spec.version       = Loess::VERSION
  spec.authors       = ["Swanand Pagnis"]
  spec.email         = ["swanand.pagnis@gmail.com"]
  spec.summary       = %q{A Simple LOESS / LOWESS calculator built in Ruby}
  spec.description   = %q{Perfect if you want to plot a line graph or scatter plot and a loess regression}
  spec.homepage      = "https://github.com/swanandp/loess.rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "rjb"
end
