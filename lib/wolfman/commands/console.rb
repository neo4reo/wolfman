module Wolfman
  CLI.define_command do
    name "console"
    summary "open a console on an EC2 machine"
    usage "console -s SERVICE -e ENV"
    description <<-DESCRIPTION
Examples:

    $ #{Paint["wolfman console -s poseidon -e staging", :magenta]}
    # opens an SSH console into poseidon staging
    DESCRIPTION

    option :s, :service, "service name (my-service)", argument: :required
    option :e, :env, "environment (production, staging, ...)", argument: :required

    run do |opts, args, cmd|
      if !opts[:env].present? || !opts[:service].present?
        puts cmd.help
        exit 1
      end

      if !AWS.configured?
        puts "Error: must configure AWS with #{Paint["wolfman config aws", :magenta]}."
        exit 1
      end

      begin
        env = AWS.find_environment!(opts[:env])
        puts "Searching environment #{Paint[env, :magenta, :bold]} for instances..."
        instances = AWS.find_instances!(env, opts[:service])
        puts "Found #{Paint[instances.size, :green]} instance(s) corresponding to #{Paint[opts[:service], :green]}"
      rescue AWS::AWSError => e
        puts e.message
        exit 1
      end

      instance = instances.first
      instance_name = AWS.instance_name(instance)
      puts "Establishing SSH connection to #{Paint[instance_name, :blue, :bold]} at #{Paint[instance.private_ip_address, :green]}..."
    end
  end
end
