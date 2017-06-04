module Wolfman
  CLI.define_command do
    name "config"
    summary "configure AWS and Rundeck connection settings"
    usage "config [SERVICE]"
    description <<-DESCRIPTION
Configures your AWS and Rundeck login credentials, and the endpoints used for
accessing these services. Running this command will create or update your
~/.wolfmanrc to store these credentials for future use.

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
        config[:domain] = ask("Primary domain: (ex: #{Paint["my-service.com", :red]})")
        config[:protocol] = ask("http or https? ") { |q| q.validate = /\Ahttps?\z/ }
      end

      if service == "rundeck"
        config[:host] = ask("Rundeck host (ex: #{Paint["https://rundeck.example.com", :red]}): ")
        config[:username] = ask("Rundeck username: ")
        config[:password] = ask("Rundeck password: ") { |q| q.echo = "*" }

        # TODO: verify Rundeck connection
      end

      Config.save!(service, config)

      puts "\nDone configuring #{service}!"
    end
  end
end
