module Wolfman
  CLI.define_command do
    name "open"
    summary "open a service in your web browser"
    description <<-HELP
Examples:

    $ wolfman open www
    # opens https://www.wealthsimple.com

    $ wolfman open www-staging /magazine
    # opens https://www-staging.wealthsimple.com/magazine

    $ wolfman open rundeck
    # opens https://rundeck.iad.w10e.com
HELP

    run do |opts, args|
      identifier, path = args
      url = Config.get(:open, identifier)
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
