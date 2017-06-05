module Wolfman
  CLI = Cri::Command.define do
    name "wolfman"
    description <<-DESCRIPTION
Run a command:
    #{Paint["wolfman COMMAND [command-specific-options]", :magenta]}

Get help for a specific command:
    #{Paint["wolfman help COMMAND", :magenta]}
    DESCRIPTION
    summary "CLI for Rundeck, CircleCI, and AWS EC2"

    run do |opts, args, cmd|
      if !opts.present? && !args.present?
        puts cmd.help
        exit 0
      end
    end
  end

  CLI.add_command Cri::Command.new_basic_help
end
