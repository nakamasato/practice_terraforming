# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  module Resource
    describe IamRolePolicyAttachment do
      let(:client) do
        Aws::IAM::Client.new(stub_responses: true)
      end

      describe ".tf" do
        xit "should generate tf" do
          expect(described_class.tf(client: client)).to eq <<~EOS
            resource "aws_iam_role_policy_attachment" "resource_name" {

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
