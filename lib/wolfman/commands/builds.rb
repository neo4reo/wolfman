module Wolfman
  CLI.define_command do
    name "builds"
    summary "manage circleci builds"
    usage "builds -a APP [-b BRANCH]"
    description <<-DESCRIPTION
Examples:

    $ #{Paint["wolfman builds -a myapp", :magenta]}
    # lists recent job executions for myapp (all branches)

    $ #{Paint["wolfman builds -a myapp -b develop", :magenta]}
    # lists recent job executions for myapp (develop branch only)
DESCRIPTION

    option :a, :app, "app name (myapp)", argument: :required
    option :b, :branch, "branch name", argument: :required

    run do |opts, args, cmd|
      opts[:branch] ||= "master"
      if !opts[:branch].present? || !opts[:app].present?
        puts cmd.help
        exit 1
      end

      if !CircleCI.configured?
        puts "Error: must configure CircleCI with #{Paint["wolfman config circleci", :magenta]}."
        exit 1
      end

      begin
        builds = CircleCI.recent_builds!(opts[:app], opts[:branch])
      rescue CircleCI::CircleCIError => e
        puts e.message
        exit 1
      end

      if builds.empty?
        puts "No builds found for #{Paint[opts[:app], :magenta]} on branch #{Paint[opts[:branch], :magenta]}."
        exit 0
      end

      puts "=== #{Paint[opts[:app], :blue, :bold]} #{Paint[opts[:branch], :magenta, :bold]}"

      builds.first(10).each do |build|
        status_mark = case build.status
        when "success", "fixed" then Paint["✓", :green]
        when "running", "queued", "scheduled", "retried" then Paint["●", "gold"]
        else Paint["✗", :red] # failed, no_tests, etc
        end

        # Format in terms of local time, not UTC.
        daetime_local = DateTime.parse(build.usage_queued_at).to_time

        puts "%{status_mark} %{status} v%{version} at %{datetime} by %{user}" % {
          status_mark: status_mark,
          status: Paint[build.status, :white],
          datetime: daetime_local,
          user: Paint[build.user&.login || build.author_name, :magenta],
          version: Paint[build.build_num, :yellow],
        }
      end
    end
  end
end
