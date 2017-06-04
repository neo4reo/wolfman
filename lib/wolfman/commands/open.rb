module Wolfman
  module Commands
    class Open
      def name
        "open"
      end

      def description
        "open a service in a web browser"
      end

      def help
        <<-HELP
Examples:

    $ wolfman open www
    # opens https://www.wealthsimple.com

    $ wolfman open www-staging /magazine
    # opens https://www-staging.wealthsimple.com/magazine

    $ wolfman open rundeck
    # opens https://rundeck.iad.w10e.com
        HELP
      end

      def run(identifier, path = "")
        url = Config.get(:open, identifier)
        url ||= Config.get(:open, :default) % {identifier: identifier}
        if path.present?
          url += "/" if !url.ends_with?("/")
          path = path.sub(%r{^/}, "")
          url += path
        end
        Launchy.open(url)
      end
    end
  end
end
