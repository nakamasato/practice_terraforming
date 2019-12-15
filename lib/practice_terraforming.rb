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
require "practice_terraforming/resource/iam_role_policy_attachment"
require "practice_terraforming/resource/iam_user_policy_attachment"
require "practice_terraforming/resource/iam_group_policy_attachment"
require "practice_terraforming/resource/iam_policy_attachment"
require "practice_terraforming/resource/s3"
