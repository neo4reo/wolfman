module Wolfman
  CLI = Cri::Command.new_basic_root.modify do
    name "wolfman"
    usage "wolfman COMMAND [--app APP] [command-specific-options]"
    summary "CLI for Rundeck and the AWS VPC infrastructure"

    run do |opts, args, cmd|
      if !opts.present? && !args.present?
        puts cmd.help
      end
    end
  end
end
