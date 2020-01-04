# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  module Resource
    describe IAMUserGroupMembership do
      let(:client) do
        # TODO: Select appropriate Client class from here:
        # http://docs.aws.amazon.com/sdkforruby/api/index.html
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:groups) do
        [
          {
            path: "/",
            group_name: "hoge_group",
            group_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:group/hoge_group",
            create_date: Time.parse("2015-04-01 12:34:56 UTC")
          },
        ]
      end

      let(:get_group) do
        {
          group: {
            path: "/",
            group_name: "hoge_group",
            group_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:group/hoge_group",
            create_date: Time.parse("2015-04-01 12:34:56 UTC")
          },
          users: [{
            path: 'path',
            user_name: "tanaka",
            user_id: 'id',
            arn: 'arn',
            create_date: Time.parse("2015-04-01 12:34:56 UTC")
          },
                  {
                    path: 'path',
                    user_name: "john",
                    user_id: 'id',
                    arn: 'arn',
                    create_date: Time.parse("2015-04-01 12:34:56 UTC")
                  }]
        }
      end

      before do
        client.stub_responses(:list_groups, groups: groups)
        client.stub_responses(:get_group, lambda { |_context|
                                            get_group
                                          })
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<~EOS
            resource "aws_iam_user_group_membership" "tanaka-hoge_group-membership" {
                user   = "tanaka"
                groups = [
                  "hoge_group"
                ]
            }

            resource "aws_iam_user_group_membership" "john-hoge_group-membership" {
                user   = "john"
                groups = [
                  "hoge_group"
                ]
            }

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
                                                                  "aws_iam_user_group_membership.tanaka-hoge_group-membership" => {
                                                                    "type" => "aws_iam_user_group_membership",
                                                                    "primary" => {
                                                                      "id" => "tanaka-hoge_group-membership",
                                                                      "attributes" => {
                                                                        "id" => "tanaka-hoge_group-membership",
                                                                        "groups.#" => "1",
                                                                        "groups.1" => "hoge_group",
                                                                        "user" => "tanaka"
                                                                      }
                                                                    }
                                                                  },
                                                                  "aws_iam_user_group_membership.john-hoge_group-membership" => {
                                                                    "type" => "aws_iam_user_group_membership",
                                                                    "primary" => {
                                                                      "id" => "john-hoge_group-membership",
                                                                      "attributes" => {
                                                                        "id" => "john-hoge_group-membership",
                                                                        "groups.#" => "1",
                                                                        "groups.1" => "hoge_group",
                                                                        "user" => "john"
                                                                      }
                                                                    }
                                                                  }
                                                                })
        end
      end
    end
  end
end
