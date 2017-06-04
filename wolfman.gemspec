# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wolfman/version'

Gem::Specification.new do |spec|
  spec.name          = "wolfman"
  spec.version       = Wolfman::VERSION
  spec.authors       = ["Peter Graham"]
  spec.email         = ["peter@wealthsimple.com"]

  spec.summary       = %q{CLI tool for VPC}
  spec.description   = %q{Command line interface for the AWS VPC infrastructure.}
  spec.homepage      = "https://github.com/wealthsimple/wolfman"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.3.0"

  spec.add_dependency "activesupport", "5.1.1"
  spec.add_dependency "aws-sdk", "2.9.28"
  spec.add_dependency "cri", "2.9.1"
  spec.add_dependency "faraday", "0.12.1"
  spec.add_dependency "faraday-cookie_jar", "0.0.6"
  spec.add_dependency "highline", "1.7.8"
  spec.add_dependency "launchy", "2.4.3"
  spec.add_dependency "paint", "2.0.0"
  spec.add_dependency "recursive-open-struct"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "rspec-collection_matchers"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2"
  spec.add_development_dependency "webmock", "~> 3.0"
end
