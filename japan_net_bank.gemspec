# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'japan_net_bank/version'

Gem::Specification.new do |spec|
  spec.name          = "japan_net_bank"
  spec.version       = JapanNetBank::VERSION
  spec.authors       = ["INOUE Takuya"]
  spec.email         = ["inouetakuya5@gmail.com"]
  spec.summary       = %q{A toolkit for generating Japan Net Bank CSV to transfer.}
  spec.description   = %q{The best way to generate Japan Net Bank CSV to transfer.}
  spec.homepage      = "https://github.com/pepabo/japan_net_bank"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "activemodel"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
