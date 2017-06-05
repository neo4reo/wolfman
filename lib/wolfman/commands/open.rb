module Wolfman
  CLI.define_command do
    name "open"
    summary "open an app/service in your web browser"
    usage "open SERVICE [PATH]"
    description <<-DESCRIPTION
Examples:

    $ #{Paint["wolfman open www", :magenta]}
    # opens #{Paint["https://www.example.com", :blue]}

    $ #{Paint["wolfman open staging /magazine", :magenta]}
    # opens #{Paint["https://staging.example.com/magazine", :blue]}

    $ #{Paint["wolfman open rundeck", :magenta]}
    # opens #{Paint["https://rundeck.host.com", :blue]}
    DESCRIPTION

    run do |_opts, args, cmd|
      if !args.present?
        puts cmd.help
        exit 0
      end

      identifier, path = args
      url = Config.get(:open, identifier)
      if !url.present?
        protocol = Config.get(:open, :protocol)
        domain = Config.get(:open, :domain)
        if !protocol.present? || !domain.present?
          puts "Error: must configure primary domain with #{Paint["wolfman config open", :magenta]}."
          exit 1
        end
        url = "#{protocol}://#{identifier}.#{domain}"
      end
      url ||= Config.get(:open, :default) % {identifier: identifier}
      if path.present?
        url += "/" if !url.ends_with?("/")
        path = path.sub(%r{^/}, "")
        url += path
      end
      puts "Launching #{Paint[url, :blue]}"
      Launchy.open(url)
    end
  end
end
