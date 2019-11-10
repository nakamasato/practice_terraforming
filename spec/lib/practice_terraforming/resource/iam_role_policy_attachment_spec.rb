# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  module Resource
    describe IamRolePolicyAttachment do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      let(:roles) do
        [
          {
            path: "/",
            role_name: "hoge_role",
            role_id: "ABCDEFGHIJKLMN1234567",
            arn: "arn:aws:iam::123456789012:role/hoge_role",
            create_date: Time.parse("2015-04-01 12:34:56 UTC"),
            assume_role_policy_document: "%7B%22Version%22%3A%222008-10-17%22%2C%22Statement%22%3A%5B%7B%22Sid%22%3A%22%22%2C%22Effect%22%3A%22Allow%22%2C%22Principal%22%3A%7B%22Service%22%3A%22ec2.amazonaws.com%22%7D%2C%22Action%22%3A%22sts%3AAssumeRole%22%7D%5D%7D",
          },
        ]
      end

      let(:list_attached_role_policies_hoge) do
        {
               attached_policies: [
                 {
                   policy_name: "hoge_policy",
                   policy_arn: "arn:aws:iam::123456789012:policy/hoge-policy",
                 },
                 {
                   policy_name: "fuga_policy",
                   policy_arn: "arn:aws:iam::345678901234:policy/fuga-policy",
                 }
               ]
        }
      end

      before do
        client.stub_responses(:list_roles, roles: roles)
        client.stub_responses(:list_attached_role_policies, -> (context) {
                                list_attached_role_policies_hoge
                              })
      end

      describe ".tf" do
        it "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<~EOS
resource "aws_iam_role_policy_attachment" "hoge_role-hoge_policy-attachment" {
    policy_arn = "arn:aws:iam::123456789012:policy/hoge-policy"
    role       = "hoge_role"
}

resource "aws_iam_role_policy_attachment" "hoge_role-fuga_policy-attachment" {
    policy_arn = "arn:aws:iam::345678901234:policy/fuga-policy"
    role       = "hoge_role"
}


          EOS
        end
      end

      describe ".tfstate" do
        xit "should generate tfstate" do
          expect(described_class.tfstate(client: client)).to eq({
                                                                  "aws_iam_role_policy_attachment.resource_name" => {
                                                                    "type" => "aws_iam_role_policy_attachment",
                                                                    "primary" => {
                                                                      "id" => "",
                                                                      "attributes" => {
                                                                      }
                                                                    }
                                                                  }
                                                                })
        end
      end
    end
  end
end
