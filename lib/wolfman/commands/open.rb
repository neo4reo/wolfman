module Wolfman
  module Commands
    class Open
      def name
        "open"
      end

      def description
        "open a service in your browser"
      end

      def help
        <<-HELP
Examples:

    $ wolfman open wealthsimple-staging
    # opens https://staging.wealthsimple.com

    $ wolfman open www
    # opens https://www.wealthsimple.com

    $ wolfman open rundeck
    # opens https://rundeck.iad.w10e.com
        HELP
      end

      def run(app)
        url = Config.get(:open, app)
        if url.present?
          Launchy.open(url)
        else
          puts "Unable to find #{app}."
        end
      end
    end
  end
end
