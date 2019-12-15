# frozen_string_literal: true

module PracticeTerraforming
  module Resource
    class IAMGroupPolicyAttachment
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
        apply_template(@client, "tf/iam_group_policy_attachment")
      end

      def tfstate
        iam_group_policy_attachments.inject({}) do |resources, group_policy_attachment|
          attributes = {
            "id" => group_policy_attachment[:name],
            "policy_arn" => group_policy_attachment[:policy_arn],
            "group" => group_policy_attachment[:group]
          }
          resources["aws_iam_group_policy_attachment.#{module_name_of(group_policy_attachment)}"] = {
            "type" => "aws_iam_group_policy_attachment",
            "primary" => {
              "id" => group_policy_attachment[:name],
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def attachment_name_from(group, policy)
        "#{group.group_name}-#{policy.policy_name}-attachment"
      end

      def iam_groups
        @client.list_groups.map(&:groups).flatten
      end

      def policies_attached_to(group)
        @client.list_attached_group_policies(group_name: group.group_name).attached_policies
      end

      def iam_group_policy_attachments
        iam_groups.map do |group|
          policies_attached_to(group).map do |policy|
            {
              group: group.group_name,
              policy_arn: policy.policy_arn,
              name: attachment_name_from(group, policy)
            }
          end
        end.flatten
      end

      def module_name_of(group_policy_attachment)
        normalize_module_name(group_policy_attachment[:name])
      end
    end
  end
end
