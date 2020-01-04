# frozen_string_literal: true

module PracticeTerraforming
  class CLI < Thor
    class_option :merge, type: :string, desc: "tfstate file to merge"
    class_option :overwrite, type: :boolean, desc: "Overwrite existing tfstate"
    class_option :tfstate, type: :boolean, desc: "Generate tfstate"
    class_option :profile, type: :string, desc: "AWS credentials profile"
    class_option :region, type: :string, desc: "AWS region"
    class_option :assume, type: :string, desc: "Role ARN to assume"
    class_option :use_bundled_cert,
                 type: :boolean,
                 desc: "Use the bundled CA certificate from AWS SDK"

    # Subcommand name should be acronym.
    desc "iamr", "Iam Role"
    def iamr
      execute(PracticeTerraforming::Resource::IAMRole, options)
    end

    desc "iamu", "Iam User"
    def iamu
      execute(PracticeTerraforming::Resource::IAMUser, options)
    end
    desc "s3", "S3"
    def s3
      execute(PracticeTerraforming::Resource::S3, options)
    end

    desc "iampa", "Iam Policy Attachment"
    def iampa
      execute(PracticeTerraforming::Resource::IamPolicyAttachment, options)
    end

    desc "iamrpa", "Iam Role Policy Attachment"
    def iamrpa
      execute(PracticeTerraforming::Resource::IamRolePolicyAttachment, options)
    end

    desc "iamupa", "Iam User Policy Attachment"
    def iamupa
      execute(PracticeTerraforming::Resource::IAMUserPolicyAttachment, options)
    end

    desc "iamgpa", "Iam Group Policy Attachment"
    def iamgpa
      execute(PracticeTerraforming::Resource::IAMGroupPolicyAttachment, options)
    end

    desc "iamugm", "Iam User Group Membership"
    def iamugm
      execute(PracticeTerraforming::Resource::IAMUserGroupMembership, options)
    end

    private

    def configure_aws(options)
      Aws.config[:credentials] = Aws::SharedCredentials.new(profile_name: options[:profile]) if options[:profile]
      Aws.config[:region] = options[:region] if options[:region]

      if options[:assume]
        args = { role_arn: options[:assume], role_session_name: "terraforming-session-#{Time.now.to_i}" }
        args[:client] = Aws::STS::Client.new(profile: options[:profile]) if options[:profile]
        Aws.config[:credentials] = Aws::AssumeRoleCredentials.new(args)
      end

      Aws.use_bundled_cert! if options[:use_bundled_cert]
    end

    def execute(klass, options)
      configure_aws(options)
      result = options[:tfstate] ? tfstate(klass, options[:merge]) : tf(klass)

      if options[:tfstate] && options[:merge] && options[:overwrite]
        open(options[:merge], "w+") do |f|
          f.write(result)
          f.flush
        end
      else
        puts result
      end
    end

    def tf(klass)
      klass.tf
    end

    def tfstate(klass, tfstate_path)
      tfstate = tfstate_path ? MultiJson.load(open(tfstate_path).read) : tfstate_skeleton
      tfstate["serial"] = tfstate["serial"] + 1
      tfstate["modules"][0]["resources"] = tfstate["modules"][0]["resources"].merge(klass.tfstate)
      MultiJson.encode(tfstate, pretty: true)
    end

    def tfstate_skeleton
      {
        "version" => 1,
        "serial" => 0,
        "modules" => [
          {
            "path" => [
              "root"
            ],
            "outputs" => {},
            "resources" => {}
          }
        ]
      }
    end
  end
end
