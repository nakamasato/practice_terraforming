[![CircleCI](https://circleci.com/gh/nakamasato/practice_terraforming.svg?style=svg&circle-token=c3fbff2dec3543a4fce9fd86907f3b6cc9bdfeba)](https://circleci.com/gh/nakamasato/practice_terraforming)

# PracticeTerraforming

## Description

This is just for practice! There's not `IAMRolePolicyAttachment`, `IAMUserPolicyAttachment` and `IAMGroupPolicyAttachment` in the original repo. So, I implemented them and also sent pull requests. This repo is used to check before sending those pull requests.

## Installation

Add this line to your application's Gemfile (https://rubygems.org/gems/practice_terraforming):

```ruby
gem 'practice_terraforming'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install practice_terraforming

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nakamasato/practice_terraforming. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PracticeTerraforming project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nakamasato/practice_terraforming/blob/master/CODE_OF_CONDUCT.md).

# How I created this

## Prepare Gem

```
bundle gem practice_terraforming
```

## Entrypoint of practice_terraforming

`bin/practice_terraforming`

CLI command (extended Thor)

## lib/practice_terraforming.rb

`lib/practice_terraforming.rb` just requires all the dependencies

## cli definition

`lib/practice_terraforming/cli.rb`

Basically, just copied from `terraforming/lib/terraforming/cli.rb`. Deleted resources but `iam_role` and `s3`

## AWS Resources (Main logic to generate tfstate/tf)

```
lib/practice_terraforming/resource/iam_role.rb
lib/practice_terraforming/resource/s3.rb
```

Resource file is generated by `script/generate` but need to update `tfstate` method

## Util

`lib/practice_terraforming/util.rb`

Just copied from `terraforming/lib/terraforming/util.rb`

## Gemspec

`practice_terraforming.gemspec`

Wrote dependencies with `spec.add_dependency` and `spec.add_development_dependency`

## Templates

- resource.erb.erb -> tf file
- resource.rb.erb -> resource class to write logic to generate tf file
- resource_spec.rb.erb -> spec file

## Spec

|spec file|memo|
|---|---|
|spec/fixtures/terraform.tfstate|copied from terraforming|
|spec/lib/practice_terraforming/cli_spec.rb|copied from terraforming|
|spec/lib/practice_terraforming/resource/<resource>.rb|generated by `script/generate` but need to write by yourself|


## Create Resource

1. generate templates with `script/generate`

    ```
    script/generate iam_policy_attachment
    ==> Generate iam_policy_attachment.rb
    ==> Generate iam_policy_attachment_spec.rb
    ==> Generate iam_policy_attachment.erb

    Add below code by hand.

    lib/practice_terraforming.rb:

        require "practice_terraforming/resource/iam_policy_attachment"

    lib/practice_terraforming/cli.rb:

        module PracticeTerraforming
          class CLI < Thor

            # Subcommand name should be acronym.
            desc "iam_policy_attachment", "Iam Policy Attachment"
            def iam_policy_attachment
              execute(PracticeTerraforming::Resource::IamPolicyAttachment, options)
            end

    spec/lib/practice_terraforming/cli_spec.rb:

        module PracticeTerraforming
          describe CLI do
            context "resources" do
            describe "iam_policy_attachment" do
              let(:klass)   { PracticeTerraforming::Resource::IamPolicyAttachment }
              let(:command) { :iam_policy_attachment }

              it_behaves_like "CLI examples"
            end
    ```

1. As the message says, add those codes.

    Need to chagnge a little bit

    lib/practice_terraforming/cli.rb:

    ```diff
    -    desc "iam_policy_attachment", "Iam Policy Attachment"
    -    def iam_policy_attachment
    -      execute(PracticeTerraforming::Resource::IamPolicyAttachment, options)
    +    desc "iampa", "Iam Policy Attachment"
    +    def iampa
    +      execute(PracticeTerraforming::Resource::IAMPolicyAttachment, options)
    ```

    spec/lib/practice_terraforming/cli_spec.rb:


    ```diff
    -    describe "iam_policy_attachment" do
    -      let(:klass)   { PracticeTerraforming::Resource::IamPolicyAttachment }
    -      let(:command) { :iam_policy_attachment }
    +    describe "iampa" do
    +      let(:klass)   { PracticeTerraforming::Resource::IAMPolicyAttachment }
    +      let(:command) { :iampa }
    ```

1. `lib/practice_terraforming/resource/iam_policy_attachment.rb`: Change Aws client and write logic in `tfstate` method

    Use aws-sdk-<resource> to get the input data

    ```diff
           # TODO: Select appropriate Client class from here:
           # http://docs.aws.amazon.com/sdkforruby/api/index.html
    -      def self.tf(client: Aws::SomeResource::Client.new)
    +      def self.tf(client: Aws::IAM::Client.new)
             self.new(client).tf
           end

           # TODO: Select appropriate Client class from here:
           # http://docs.aws.amazon.com/sdkforruby/api/index.html
    -      def self.tfstate(client: Aws::SomeResource::Client.new)
    +      def self.tfstate(client: Aws::IAM::Client.new)
             self.new(client).tfstate
           end
    ```

    write the logic to generate tf/tfstate file.
    1. tf -> only need to update the template file, which appears in the next step
    2. tfstate -> get resource list using private method, format them into resources and return them
    3. As for private methods:
      - module_name_of(<resource>) -> used for module name of terraform to be imported
      - <api method name, e.g. entities_for_policy> -> get the resource info with aws-sdk
      - other -> make a list of resources to be used in `tfstate` method

1. `lib/practice_terraforming/template/tf/iam_policy_attachment.erb`: Update the erb based on the corresponding terraform resource.

    ```
    <% iam_policy_attachments.each do |policy_attachment| -%>
    resource "aws_iam_policy_attachment" "<%= module_name_of(policy_attachment) %>" {
        name       = "<%= policy_attachment[:name] %>"
        policy_arn = "<%= policy_attachment[:arn] %>"
        groups     = <%= policy_attachment[:entities].policy_groups.map(&:group_name).inspect %>
        users      = <%= policy_attachment[:entities].policy_users.map(&:user_name).inspect %>
        roles      = <%= policy_attachment[:entities].policy_roles.map(&:role_name).inspect %>
    }

    <% end -%>
    ```

1. `spec/lib/practice_terraforming/resource/iam_policy_attachment_spec.rb`: Change Aws client and write test for tf and tfstate

    Change Aws client

    ```diff
     module PracticeTerraforming
       module Resource
    -    describe IamPolicyAttachment do
    +    describe IAMPolicyAttachment do
           let(:client) do
             # TODO: Select appropriate Client class from here:
             # http://docs.aws.amazon.com/sdkforruby/api/index.html
    -        Aws::SomeResource::Client.new(stub_responses: true)
    +        Aws::IAM::Client.new(stub_responses: true)
           end

           describe ".tf" do
    ```

    Test Perspective:
    1. Create aws sdk result using stub.
    2. Use the module to generate tf/tfstate.
    3. Compare expected one and generated one.

        ```ruby
        irb(main):007:0> client.list_policies.policies[0]
        => #<struct Aws::IAM::Types::Policy policy_name="test-policy", policy_id="ABCDEFG", arn="arn:aws:iam::123456789:policy/test-policy", path="/", default_version_id="v1", attachment_count=1, permissions_boundary_usage_count=0, is_attachable=true, description=nil, create_date=2019-01-01 00:00:00 UTC, update_date=2019-01-02 00:00:00 UTC>
        irb(main):008:0> client.list_entities_for_policy(policy_arn: "arn:aws:iam::123456789:policy/test-policy")
        => #<struct Aws::IAM::Types::ListEntitiesForPolicyResponse policy_groups=[#<struct Aws::IAM::Types::PolicyGroup group_name="test-group", group_id="ABCDEFG">], policy_users=[], policy_roles=[], is_truncated=false, marker=nil>
        ```

        ```ruby
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
                description: nil,
              }
            ]
        end

        let(:entities_for_policy) do
          {
            policy_groups: [
              { group_name: "test-group",  group_id: "ABCDEFG" },
            ],
            policy_users: [],
            policy_roles: [],
         }
        end

        before do
          client.stub_responses(:list_policies, policies: policies)
          client.stub_responses(:list_entities_for_policy, [entities_for_policy])
        end
        ```

## Install on local

### Build

```bash
gem build practice_terraforming.gemspec
```

the above command will generate the `practice_terraforming-X.X.X.gem`

### Install

0.1.0 as an example

```bash
gem install practice_terraforming-0.1.0.gem
Successfully installed practice_terraforming-0.1.0
Parsing documentation for practice_terraforming-0.1.0
Installing ri documentation for practice_terraforming-0.1.0
Done installing documentation for practice_terraforming after 0 seconds
1 gem installed
```

### Check

```bash
practice_terraforming
Commands:
  practice_terraforming help [COMMAND]  # Describe available commands or one specific command
  practice_terraforming iamgpa          # Iam Group Policy Attachment
  practice_terraforming iampa           # Iam Policy Attachment
  practice_terraforming iamr            # Iam Role
  practice_terraforming iamrpa          # Iam Role Policy Attachment
  practice_terraforming iamupa          # Iam User Policy Attachment
  practice_terraforming s3              # S3

Options:
  [--merge=MERGE]                                # tfstate file to merge
  [--overwrite], [--no-overwrite]                # Overwrite existing tfstate
  [--tfstate], [--no-tfstate]                    # Generate tfstate
  [--profile=PROFILE]                            # AWS credentials profile
  [--region=REGION]                              # AWS region
  [--assume=ASSUME]                              # Role ARN to assume
  [--use-bundled-cert], [--no-use-bundled-cert]  # Use the bundled CA certificate from AWS SDK
```

## Table for aws-sdk and terraforming

|terraforming resource|aws-sdk|
|---|---|
|IAMRolePolicyAttachment|`list_roles` and `list_attached_role_policies` for all extracted roles |
|IAMGroupPolicyAttachment|`list_users` and `list_attached_user_policies` for all extracted users|
|IAMGroupPolicyAttachment|`list_groups` and `list_attached_group_policies` for all extracted groups|
