module Wolfman
  CLI.define_command do
    name "jobs"
    summary "manage rundeck jobs"
    usage "jobs -s SERVICE -e ENV"
    description <<-DESCRIPTION
Examples:

    $ #{Paint["wolfman jobs -s poseidon -e staging", :magenta]}
    # lists recent job executions for Poseidon (staging)
DESCRIPTION

    option :s, :service, "service name", argument: :required
    option :e, :env, "environment name (production, staging, ...)", argument: :required

    run do |opts, args, cmd|
      if !opts[:service].present? || !opts[:env].present?
        puts cmd.help
        exit 1
      end

      if !Rundeck.configured?
        puts "Error: must configure Rundeck with #{Paint["wolfman config rundeck", :magenta]}."
        exit 1
      end

      begin
        projects = Rundeck.get!("/projects")
        project = projects.find do |project|
          project.name.downcase.include?(opts[:env])
        end
        if !project.present?
          puts "Unrecognized environment #{opts[:env]}."
          puts "Specify env that matches one of the following:"
          puts projects.map { |project| "- #{Paint[project.name.downcase, :magenta]}" }.join("\n")
          exit 1
        end
        executions = Rundeck.get!("/project/#{project.name}/executions?jobFilter=#{opts[:service]}")
        executions = executions.executions
        if !executions.present?
          puts "No executions found for #{opts[:service]} in #{project.name}."
          exit 0
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

          puts "%{status_mark} %{status} %{version} at %{datetime} by %{user}" % {
            status_mark: status_mark,
            status: Paint[execution.status, :white],
            datetime: execution.send("date-started").date,
            user: Paint[execution.user, :magenta],
            version: version,
          }
        end
      rescue Rundeck::RundeckError => e
        puts e.message
        exit 1
      end
    end
  end
end
