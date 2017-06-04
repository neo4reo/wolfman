module Wolfman
  class Cli
    def initialize
      @commands = Commands.constants.select { |c| Commands.const_get(c).is_a? Class }
    end

    def help
      <<-HELP
Usage: wolfman COMMAND [--app APP] [command-specific-options]

For help on a specific command, type wolfman help COMMAND:

      HELP
    end
  end
end
