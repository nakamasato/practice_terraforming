# frozen_string_literal: true

require "coveralls"
require "simplecov"

SimpleCov.start do
  add_filter "lib/practice_terraforming.rb"
  add_filter "lib/practice_terraforming/version.rb"

  formatter SimpleCov::Formatter::MultiFormatter.new([
                                                       Coveralls::SimpleCov::Formatter,
                                                       SimpleCov::Formatter::HTMLFormatter,
                                                     ])
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'practice_terraforming'

require 'tempfile'
require 'time'

def fixture_path(fixture_name)
  File.join(File.dirname(__FILE__), "fixtures", fixture_name)
end

def tfstate_fixture_path
  fixture_path("terraform.tfstate")
end

def tfstate_fixture
  JSON.parse(open(tfstate_fixture_path).read)
end
