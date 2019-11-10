# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  module Resource
    describe IamPolicyAttachment do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:policies) do
        [
          {
            policy_name: "test-policy",
            policy_id: "ABCDEFG",
            arn: "arn:aws:iam::123456789:policy/test-policy",
            path: "/",
            default_version_id: "v1",
            attachment_count: 1,
            is_attachable: true,
            create_date: Time.parse("2019-01-01 00:00:00 UTC"),
            update_date: Time.parse("2019-01-02 00:00:00 UTC"),
            description: nil
          }
        ]
      end

      let(:entities_for_policy) do
        {
          policy_groups: [
            { group_name: "test-group", group_id: "ABCDEFG" },
          ],
          policy_users: [],
          policy_roles: []
        }
      end

      before do
        client.stub_responses(:list_policies, policies: policies)
        client.stub_responses(:list_entities_for_policy, [entities_for_policy])
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<~EOS
            resource "aws_iam_policy_attachment" "test-policy-policy-attachment" {
                name       = "test-policy-policy-attachment"
                policy_arn = "arn:aws:iam::123456789:policy/test-policy"
                groups     = ["test-group"]
                users      = []
                roles      = []
            }

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
                                                                  "aws_iam_policy_attachment.test-policy-policy-attachment" => {
                                                                    "type" => "aws_iam_policy_attachment",
                                                                    "primary" => {
                                                                      "id" => "test-policy-policy-attachment",
                                                                      "attributes" => {
                                                                        "id" => "test-policy-policy-attachment",
                                                                        "name" => "test-policy-policy-attachment",
                                                                        "policy_arn" => "arn:aws:iam::123456789:policy/test-policy",
                                                                        "groups.#" => "1",
                                                                        "users.#" => "0",
                                                                        "roles.#" => "0"
                                                                      }
                                                                    }
                                                                  }
                                                                })
        end
      end
    end
  end
end
