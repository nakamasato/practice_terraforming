# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  module Resource
    describe IAMUserPolicyAttachment do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:users) do
        [
          {
            path: "/",
            user_name: "hoge_user",
            user_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:user/hoge_user",
            create_date: Time.parse("2015-04-01 12:34:56 UTC")
          },
        ]
      end

      let(:list_attached_user_policies_hoge) do
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
        client.stub_responses(:list_users, users: users)
        client.stub_responses(:list_attached_user_policies, lambda { |_context|
                                                              list_attached_user_policies_hoge
                                                            })
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<~EOS
            resource "aws_iam_user_policy_attachment" "hoge_user-hoge_policy-attachment" {
                policy_arn = "arn:aws:iam::123456789012:policy/hoge-policy"
                user       = "hoge_user"
            }

            resource "aws_iam_user_policy_attachment" "hoge_user-fuga_policy-attachment" {
                policy_arn = "arn:aws:iam::345678901234:policy/fuga-policy"
                user       = "hoge_user"
            }

          EOS
        end
      end

      describe ".tfstate" do
        it "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
                                                                  "aws_iam_user_policy_attachment.hoge_user-hoge_policy-attachment" => {
                                                                    "type" => "aws_iam_user_policy_attachment",
                                                                    "primary" => {
                                                                      "id" => "hoge_user-hoge_policy-attachment",
                                                                      "attributes" => {
                                                                        "id" => "hoge_user-hoge_policy-attachment",
                                                                        "policy_arn" => "arn:aws:iam::123456789012:policy/hoge-policy",
                                                                        "user" => "hoge_user"
                                                                      }
                                                                    }
                                                                  },
                                                                  "aws_iam_user_policy_attachment.hoge_user-fuga_policy-attachment" => {
                                                                    "type" => "aws_iam_user_policy_attachment",
                                                                    "primary" => {
                                                                      "id" => "hoge_user-fuga_policy-attachment",
                                                                      "attributes" => {
                                                                        "id" => "hoge_user-fuga_policy-attachment",
                                                                        "policy_arn" => "arn:aws:iam::345678901234:policy/fuga-policy",
                                                                        "user" => "hoge_user"
                                                                      }
                                                                    }
                                                                  }
                                                                })
        end
      end
    end
  end
end
