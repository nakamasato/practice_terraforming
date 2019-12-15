# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  module Resource
    describe IAMGroupPolicyAttachment do
      let(:client) do
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

      let(:list_attached_group_policies_hoge) do
        {
          attached_policies: [
            {
              policy_name: "hoge_policy",
              policy_arn: "arn:aws:iam::123456789012:policy/hoge-policy"
            },
            {
              policy_name: "fuga_policy",
              policy_arn: "arn:aws:iam::345678901234:policy/fuga-policy"
            }
          ]
        }
      end

      before do
        client.stub_responses(:list_groups, groups: groups)
        client.stub_responses(:list_attached_group_policies, lambda { |_context|
                                                               list_attached_group_policies_hoge
                                                             })
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<~EOS
            resource "aws_iam_group_policy_attachment" "hoge_group-hoge_policy-attachment" {
                policy_arn = "arn:aws:iam::123456789012:policy/hoge-policy"
                group       = "hoge_group"
            }

            resource "aws_iam_group_policy_attachment" "hoge_group-fuga_policy-attachment" {
                policy_arn = "arn:aws:iam::345678901234:policy/fuga-policy"
                group       = "hoge_group"
            }

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
                                                                  "aws_iam_group_policy_attachment.hoge_group-hoge_policy-attachment" => {
                                                                    "type" => "aws_iam_group_policy_attachment",
                                                                    "primary" => {
                                                                      "id" => "hoge_group-hoge_policy-attachment",
                                                                      "attributes" => {
                                                                        "id" => "hoge_group-hoge_policy-attachment",
                                                                        "policy_arn" => "arn:aws:iam::123456789012:policy/hoge-policy",
                                                                        "group" => "hoge_group"
                                                                      }
                                                                    }
                                                                  },
                                                                  "aws_iam_group_policy_attachment.hoge_group-fuga_policy-attachment" => {
                                                                    "type" => "aws_iam_group_policy_attachment",
                                                                    "primary" => {
                                                                      "id" => "hoge_group-fuga_policy-attachment",
                                                                      "attributes" => {
                                                                        "id" => "hoge_group-fuga_policy-attachment",
                                                                        "policy_arn" => "arn:aws:iam::345678901234:policy/fuga-policy",
                                                                        "group" => "hoge_group"
                                                                      }
                                                                    }
                                                                  }
                                                                })
        end
      end
    end
  end
end
