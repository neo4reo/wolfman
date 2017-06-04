module Wolfman
  CLI.define_command do
    name "jobs"
    summary "manage rundeck jobs"
    usage "jobs -s SERVICE -e ENV"
    description <<-DESCRIPTION
Examples:

    $ #{Paint["wolfman jobs -s poseidon -e staging", :magenta]}
    # lists recent job executions for poseidon staging
DESCRIPTION

    option :s, :service, "service name (my-service)", argument: :required
    option :e, :env, "environment (production, staging, ...)", argument: :required

    run do |opts, args, cmd|
      if !opts[:env].present? || !opts[:service].present?
        puts cmd.help
        exit 1
      end

      if !Rundeck.configured?
        puts "Error: must configure Rundeck with #{Paint["wolfman config rundeck", :magenta]}."
        exit 1
      end

      begin
        project = Rundeck.find_project!(opts[:env])
        executions = Rundeck.find_executions!(project, opts[:service])
      rescue Rundeck::RundeckError => e
        puts e.message
        exit 1
      end

      puts "=== #{Paint[project.name, :blue, :bold]} #{Paint[executions.first.job.name, :magenta, :bold]}"
      executions.first(10).each do |execution|
        status_mark = case execution.status
        when "succeeded" then Paint["✓", :green]
        when "running" then Paint["●", :yellow]
        else Paint["✗", :red] # failed, aborted, etc
        end

        app_version = execution.job.options.APP_VERSION
        if app_version
          version = Paint["v#{app_version}", :cyan]
        else
          version = ""
        end

        # Format in terms of local time, not UTC.
        daetime_local = DateTime.parse(execution.send("date-started").date).to_time

        puts "%{status_mark} %{status} %{version} at %{datetime} by %{user}" % {
          status_mark: status_mark,
          status: Paint[execution.status, :white],
          datetime: daetime_local,
          user: Paint[execution.user, :magenta],
          version: version,
        }
      end
    end
  end
end
