# frozen_string_literal: true

require "aws-sdk-iam"
require "aws-sdk-s3"
require "multi_json"
require "thor"
require "erb"

require "practice_terraforming/util"
require 'practice_terraforming/version'

require "practice_terraforming/cli"
require "practice_terraforming/resource/iam_role"
require "practice_terraforming/resource/s3"
