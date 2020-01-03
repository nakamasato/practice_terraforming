# frozen_string_literal: true

require "spec_helper"

module PracticeTerraforming
  describe CLI do
    context "resources" do
      shared_examples "CLI examples" do
        context "without --tfstate" do
          it "should export tf" do
            expect(klass).to receive(:tf).with(no_args)
            described_class.new.invoke(command, [], {})
          end
        end

        context "with --tfstate" do
          it "should export tfstate" do
            expect(klass).to receive(:tfstate).with(no_args)
            described_class.new.invoke(command, [], { tfstate: true })
          end
        end

        context "with --tfstate --merge TFSTATE" do
          it "should export merged tfstate" do
            expect(klass).to receive(:tfstate).with(no_args)
            described_class.new.invoke(command, [], { tfstate: true, merge: tfstate_fixture_path })
          end
        end
      end

      Aws.config[:sts] = {
        stub_responses: {
          get_caller_identity: {
            account: '123456789012',
            arn: 'arn:aws:iam::123456789012:user/terraforming',
            user_id: 'AAAABBBBCCCCDDDDDEEE'
          }
        }
      }

      before do
        allow(STDOUT).to receive(:puts).and_return(nil)
        allow(klass).to receive(:tf).and_return("")
        allow(klass).to receive(:tfstate).and_return({})
        allow(klass).to receive(:assume).and_return({})
      end

      describe "iamr" do
        let(:klass)   { PracticeTerraforming::Resource::IAMRole }
        let(:command) { :iamr }

        it_behaves_like "CLI examples"
      end

      describe "s3" do
        let(:klass)   { PracticeTerraforming::Resource::S3 }
        let(:command) { :s3 }

        it_behaves_like "CLI examples"
      end

      describe "iamu" do
        let(:klass)   { PracticeTerraforming::Resource::IAMUser }
        let(:command) { :iamu }

        it_behaves_like "CLI examples"
      end

      describe "iampa" do
        let(:klass)   { PracticeTerraforming::Resource::IamPolicyAttachment }
        let(:command) { :iampa }

        it_behaves_like "CLI examples"
      end

      describe "iamrpa" do
        let(:klass)   { PracticeTerraforming::Resource::IamRolePolicyAttachment }
        let(:command) { :iamrpa }

        it_behaves_like "CLI examples"
      end

      describe "iamupa" do
        let(:klass)   { PracticeTerraforming::Resource::IAMUserPolicyAttachment }
        let(:command) { :iamupa }

        it_behaves_like "CLI examples"
      end

      describe "iamgpa" do
        let(:klass)   { PracticeTerraforming::Resource::IAMGroupPolicyAttachment }
        let(:command) { :iamgpa }

        it_behaves_like "CLI examples"
      end
    end

    context "flush to stdout" do
      describe "s3" do
        let(:klass)   { PracticeTerraforming::Resource::S3 }
        let(:command) { :s3 }

        let(:tf) do
          <<~EOS
            resource "aws_s3_bucket" "hoge" {
                bucket = "hoge"
                acl    = "private"
            }

            resource "aws_s3_bucket" "fuga" {
                bucket = "fuga"
                acl    = "private"
            }

          EOS
        end

        let(:tfstate) do
          {
            "aws_s3_bucket.hoge" => {
              "type" => "aws_s3_bucket",
              "primary" => {
                "id" => "hoge",
                "attributes" => {
                  "acl" => "private",
                  "bucket" => "hoge",
                  "id" => "hoge"
                }
              }
            },
            "aws_s3_bucket.fuga" => {
              "type" => "aws_s3_bucket",
              "primary" => {
                "id" => "fuga",
                "attributes" => {
                  "acl" => "private",
                  "bucket" => "fuga",
                  "id" => "fuga"
                }
              }
            }
          }
        end

        let(:initial_tfstate) do
          {
            "version" => 1,
            "serial" => 1,
            "modules" => [
              {
                "path" => [
                  "root"
                ],
                "outputs" => {},
                "resources" => {
                  "aws_s3_bucket.hoge" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "hoge",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "hoge",
                        "id" => "hoge"
                      }
                    }
                  },
                  "aws_s3_bucket.fuga" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "fuga",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "fuga",
                        "id" => "fuga"
                      }
                    }
                  }
                }
              }
            ]
          }
        end

        let(:merged_tfstate) do
          {
            "version" => 1,
            "serial" => 89,
            "remote" => {
              "type" => "s3",
              "config" => { "bucket" => "practice_terraforming-tfstate", "key" => "tf" }
            },
            "modules" => [
              {
                "path" => ["root"],
                "outputs" => {},
                "resources" => {
                  "aws_elb.hogehoge" => {
                    "type" => "aws_elb",
                    "primary" => {
                      "id" => "hogehoge",
                      "attributes" => {
                        "availability_zones.#" => "2",
                        "connection_draining" => "true",
                        "connection_draining_timeout" => "300",
                        "cross_zone_load_balancing" => "true",
                        "dns_name" => "hoge-12345678.ap-northeast-1.elb.amazonaws.com",
                        "health_check.#" => "1",
                        "id" => "hogehoge",
                        "idle_timeout" => "60",
                        "instances.#" => "1",
                        "listener.#" => "1",
                        "name" => "hoge",
                        "security_groups.#" => "2",
                        "source_security_group" => "default",
                        "subnets.#" => "2"
                      }
                    }
                  },
                  "aws_s3_bucket.hoge" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "hoge",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "hoge",
                        "id" => "hoge"
                      }
                    }
                  },
                  "aws_s3_bucket.fuga" => {
                    "type" => "aws_s3_bucket",
                    "primary" => {
                      "id" => "fuga",
                      "attributes" => {
                        "acl" => "private",
                        "bucket" => "fuga",
                        "id" => "fuga"
                      }
                    }
                  }
                }
              }
            ]
          }
        end

        before do
          allow(klass).to receive(:tf).and_return(tf)
          allow(klass).to receive(:tfstate).and_return(tfstate)
        end

        context "without --tfstate" do
          it "should flush tf to stdout" do
            expect(STDOUT).to receive(:puts).with(tf)
            described_class.new.invoke(command, [], {})
          end
        end

        context "with --tfstate" do
          it "should flush state to stdout" do
            expect(STDOUT).to receive(:puts).with(JSON.pretty_generate(initial_tfstate))
            described_class.new.invoke(command, [], { tfstate: true })
          end
        end

        context "with --tfstate --merge TFSTATE" do
          it "should flush merged tfstate to stdout" do
            expect(STDOUT).to receive(:puts).with(JSON.pretty_generate(merged_tfstate))
            described_class.new.invoke(command, [], { tfstate: true, merge: tfstate_fixture_path })
          end
        end

        context "with --tfstate --merge TFSTATE --overwrite" do
          before do
            @tmp_tfstate = Tempfile.new("tfstate")
            @tmp_tfstate.write(open(tfstate_fixture_path).read)
            @tmp_tfstate.flush
          end

          it "should overwrite passed tfstate" do
            described_class.new.invoke(command, [], { tfstate: true, merge: @tmp_tfstate.path, overwrite: true })
            expect(open(@tmp_tfstate.path).read).to eq JSON.pretty_generate(merged_tfstate)
          end

          after do
            @tmp_tfstate.close
            @tmp_tfstate.unlink
          end
        end

        context "with --assumes and without --tfstate" do
          it "should switch roles and export tf" do
            expect(klass).to receive(:tf).with(no_args)
            described_class.new.invoke(command, [], {
                                         assume: 'arn:aws:iam::123456789123:role/test-role',
                                         region: 'ap-northeast-1'
                                       })
          end
        end

        context "with --assumes and --tfstate" do
          it "should switch roles and export tfstate" do
            expect(klass).to receive(:tfstate).with(no_args)
            described_class.new.invoke(command, [], {
                                         assume: 'arn:aws:iam::123456789123:role/test-role',
                                         region: 'ap-northeast-1',
                                         tfstate: true
                                       })
          end
        end

        context "with --assumes and --tfstate --merge TFSTATE" do
          it "should switch roles and export merged tfstate" do
            expect(klass).to receive(:tfstate).with(no_args)
            described_class.new.invoke(command, [], {
                                         assume: 'arn:aws:iam::123456789123:role/test-role',
                                         region: 'ap-northeast-1',
                                         tfstate: true,
                                         merge: tfstate_fixture_path
                                       })
          end
        end
      end
    end
  end
end
