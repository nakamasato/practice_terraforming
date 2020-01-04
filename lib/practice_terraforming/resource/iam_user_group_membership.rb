# frozen_string_literal: true

module PracticeTerraforming
  module Resource
    class IAMUserGroupMembership
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
        apply_template(@client, "tf/iam_user_group_membership")
      end

      def tfstate
        user_group_memberships.inject({}) do |resources, membership|
          attributes = {
            "id" => membership[:name],
            "groups.#" => "1",
            "groups.1" => membership[:group],
            "user" => membership[:user]
          }
          resources["aws_iam_user_group_membership.#{module_name_of(membership)}"] = {
            "type" => "aws_iam_user_group_membership",
            "primary" => {
              "id" => membership[:name],
              "attributes" => attributes
            }
          }

          resources
        end
      end

      private

      def user_group_membership_name_from(user, group)
        "#{user.user_name}-#{group.group_name}-membership"
      end

      def iam_groups
        @client.list_groups.map(&:groups).flatten
      end

      def group_members_of(group)
        @client.get_group(group_name: group.group_name).users
      end

      def user_group_memberships
        iam_groups.map do |group|
          group_members_of(group).map do |user|
            {
              group: group.group_name,
              user: user.user_name,
              name: user_group_membership_name_from(user, group)
            }
          end
        end.flatten
      end

      def module_name_of(membership)
        normalize_module_name(membership[:name])
      end
    end
  end
end
