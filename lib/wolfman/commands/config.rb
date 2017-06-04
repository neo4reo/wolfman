module Wolfman
  CLI.define_command do
    name "config"
    summary "configure connection settings for AWS, Rundeck, and more"
    usage "config [SERVICE]"
    description <<-DESCRIPTION
Configures your AWS and Rundeck login credentials, and the endpoints used for accessing these services.

Running this command will create or update your #{Paint["~/.wolfmanrc", :blue]} to store these credentials for future use. When storing this file on disk, it's permissions are set to #{Paint["0600", :blue]} so that only your user has read/write access.

Examples:

    $ #{Paint["wolfman config aws", :magenta]}
    # Configure AWS connection settings

    $ #{Paint["wolfman config open", :magenta]}
    # Configure #{Paint["wolfman open", :blue]} settings

    $ #{Paint["wolfman config rundeck", :magenta]}
    # Configure Rundeck connection settings
    DESCRIPTION

    run do |_opts, args, cmd|
      service = args[0]
      if !service.present? || !%w[aws open rundeck].include?(service)
        puts cmd.help
        exit 0
      end

      puts "Starting #{service} configuration...\n\n"
      config = {}

      if service == "aws"
        puts "Find your AWS account ID from the console URL:"
        puts "https://#{Paint["My_AWS_Account_ID", :red]}.signin.aws.amazon.com/console\n\n"

        config[:account_id] = ask("AWS account ID: ")
        # TODO: check for existing credentials at ~/.aws/credentials
        # https://github.com/airbnb/gem-aws-creds
        config[:access_key_id] = ask("AWS access key ID (ex: #{Paint["AKIA...", :red]}): ")
        config[:secret_access_key] = ask("AWS secret access key: ")
        config[:region] = ask("AWS region (ex: #{Paint["us-east-1", :red]}): ")

        # TODO: verify AWS connection
      end

      if service == "open"
        config[:domain] = ask("Domain (ex: #{Paint["service.com", :red]}): ")
        config[:protocol] = ask("#{Paint["http", :red]} or #{Paint["https", :red]}? ") { |q| q.validate = /\Ahttps?\z/ }
      end

      if service == "rundeck"
        config[:host] = ask("Rundeck host (ex: #{Paint["https://rundeck.example.com", :red]}): ") { |q| q.validate = /\Ahttps?/ }
        config[:username] = ask("Rundeck username: ")
        config[:password] = ask("Rundeck password: ") { |q| q.echo = "*" }

        puts "\nVerifying connection settings..."
        begin
          Rundeck.start_session!(config)
        rescue Rundeck::RundeckError => e
          puts e.message
          puts "Exiting without saving configuration."
          exit 1
        end
        puts "Connected!"
      end

      Config.save!(service, config)

      puts "\nDone configuring #{service}!"
    end
  end
end
