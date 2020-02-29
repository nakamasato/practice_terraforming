# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'practice_terraforming/version'

Gem::Specification.new do |spec|
  spec.name          = 'practice_terraforming'
  spec.version       = PracticeTerraforming::VERSION
  spec.authors       = ['masatonaka']
  spec.email         = ['masatonaka1989@gmail.com']

  spec.summary       = 'practice terraforming'
  spec.description   = 'practice terraforming'
  spec.homepage      = 'https://github.com/nakamasato/practice_terraforming'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency "aws-sdk-iam", "~> 1"
  spec.add_dependency "aws-sdk-s3", "~> 1"
  spec.add_dependency "multi_json", "~> 1.12.1"
  spec.add_dependency "thor"

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency "coveralls", "~> 0.8.13"
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency "simplecov", "~> 0.14.1"
end
