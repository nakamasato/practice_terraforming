# frozen_string_literal: true

module PracticeTerraforming
  module Resource
    class IAMUserPolicyAttachment
      include PracticeTerraforming::Util

      # TODO: Select appropriate Client class from here:
      # http://docs.aws.amazon.com/sdkforruby/api/index.html
      def self.tf(client: Aws::IAM::Client.new)
        self.new(client).tf
      end

      # TODO: Select appropriate Client class from here:
      # http://docs.aws.amazon.com/sdkforruby/api/index.html
      def self.tfstate(client: Aws::IAM::Client.new)
        self.new(client).tfstate
      end

      def initialize(client)
        @client = client
      end

      def tf
        apply_template(@client, "tf/iam_user_policy_attachment")
      end

      def tfstate
        iam_user_policy_attachments.inject({}) do |resources, user_policy_attachment|
          attributes = {
            "id" => user_policy_attachment[:name],
            "policy_arn" => user_policy_attachment[:policy_arn],
            "user" => user_policy_attachment[:user]
          }
          resources["aws_iam_user_policy_attachment.#{module_name_of(user_policy_attachment)}"] = {
            "type" => "aws_iam_user_policy_attachment",
            "primary" => {
              "id" => user_policy_attachment[:name],
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def attachment_name_from(user, policy)
        "#{user.user_name}-#{policy.policy_name}-attachment"
      end

      def iam_users
        @client.list_users.map(&:users).flatten
      end

      def policies_attached_to(user)
        @client.list_attached_user_policies(user_name: user.user_name).attached_policies
      end

      def iam_user_policy_attachments
        iam_users.map do |user|
          policies_attached_to(user).map do |policy|
            {
              user: user.user_name,
              policy_arn: policy.policy_arn,
              name: attachment_name_from(user, policy)
            }
          end
        end.flatten
      end

      def module_name_of(user_policy_attachment)
        normalize_module_name(user_policy_attachment[:name])
      end
    end
  end
end
