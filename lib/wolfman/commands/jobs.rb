module Wolfman
  CLI.define_command do
    name "jobs"
    summary "manage rundeck jobs"
    usage "jobs SERVICE"
    description <<-DESCRIPTION
Examples:

    TODO
DESCRIPTION

    run do |_opts, args, cmd|
      if !args.present?
        puts cmd.help
        exit 0
      end

      if !Rundeck.configured?
        puts "Error: must configure Rundeck with #{Paint["wolfman config rundeck", :magenta]}."
        exit 1
      end

      begin
        Rundeck.request!(:get, "/TODO")
      rescue Rundeck::RundeckError => e
        puts e.message
        exit 1
      end
    end
  end
end
