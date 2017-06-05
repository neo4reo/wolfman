module Wolfman
  CLI.define_command do
    name "console"
    summary "open a console on an EC2 machine"
    usage "console -a APP -e ENV"
    description <<-DESCRIPTION
Examples:

    $ #{Paint["wolfman console -a myapp -e staging", :magenta]}
    # opens an SSH console into myapp staging
    DESCRIPTION

    option :a, :app, "app name (myapp)", argument: :required
    option :e, :env, "environment (production, staging, ...)", argument: :required

    run do |opts, args, cmd|
      if !opts[:env].present? || !opts[:app].present?
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
        instances = AWS.find_instances!(env, opts[:app])
      rescue AWS::AWSError => e
        puts e.message
        exit 1
      end

      unique_instance_names = instances.map { |instance| AWS.instance_name(instance) }.uniq
      if unique_instance_names.size == 1
        instance_name = unique_instance_names.first
        instance = instances.first
      else
        instance_name = nil
        instance = nil
        choose do |menu|
          menu.prompt = "Choose an EC2 instance: "
          menu.choices(*unique_instance_names.map { |name| Paint[name, :blue] }) do |choice, _details|
            instance_name = Paint.unpaint(choice)
            instance = instances.find { |instance| AWS.instance_name(instance) == instance_name }
          end
        end
      end

      puts "Establishing SSH connection to #{Paint[instance_name, :blue, :bold]} at #{Paint[instance.private_ip_address, :green]}..."

      ssh_options = {
        "UseKeychain" => "yes",
        "AddKeysToAgent" => "yes",
        "ForwardAgent" => "yes",
        "TCPKeepAlive" => "yes",
        "ServerAliveInterval" => "30",
      }
      if Config.exists?(:aws, :jumpbox_host)
        ssh_options["ProxyCommand"] = %{'ssh -q #{Config.get!(:aws, :jumpbox_host)} -W "%h:%p"'}
      end
      ssh_options = ssh_options.map { |key, value| "-o #{key}=#{value}" }.join(" ")

      exec(%{ssh #{ssh_options} -t #{instance.private_ip_address} 'sudo su'})
    end
  end
end
