module Wolfman
  class Rundeck
    class RundeckError < StandardError
    end

    API_VERSION = 18

    def self.configured?
      %w[host username password].all? do |key|
        Config.exists?(:rundeck, key)
      end
    end

    def self.get!(path)
      start_session!
      response = connection.get do |request|
        path = "/#{path}" unless path.start_with?("/")
        request.url "/api/#{API_VERSION}#{path}"
        request.headers["Accept"] = "application/json"
      end
      response_json = JSON.parse(response.body)
      if response_json.is_a?(Array)
        response_json.map { |r| Resource.new(r) }
      else
        Resource.new(response_json)
      end
    end

    def self.start_session!(host: nil, username: nil, password: nil)
      return if @authenticated
      username ||= Config.get(:rundeck, :username)
      password ||= Config.get(:rundeck, :password)

      session = connection(host: host).post("/j_security_check", {
        j_username: username,
        j_password: password,
      })

      if session.headers["location"].include?("user/error")
        raise RundeckError.new("Error: invalid Rundeck username or password.")
      else
        @authenticated = true
      end
    rescue Faraday::ConnectionFailed
      raise RundeckError.new("Error: unable to connect to host. Are you connected to the VPN?")
    rescue Faraday::Error
      raise RundeckError.new("Error: unable to connect. Did you configure Rundeck correctly?")
    end

    def self.connection(host: nil)
      @connections ||= {}
      host ||= Config.get(:rundeck, :host)
      @connections[host] ||= Faraday.new(url: host) do |faraday|
        faraday.use :cookie_jar
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.use Faraday::Response::RaiseError
      end
    end

    def self.find_executions!(project, job_query)
      executions = get!("/project/#{project.name}/executions?jobFilter=#{job_query}")
      executions = executions.executions
      if !executions.present?
        raise RundeckError.new("No executions found for #{job_query} in #{project.name}.")
      end
      executions
    end

    def self.find_project!(query)
      normalized_query = normalize_name(query)
      projects = get!("/projects").select do |project|
        normalize_name(project.name).include?(normalized_query)
      end
      if projects.size != 1
        error = ["Unrecognized project #{query}."]
        error << "Specify project that matches one of the following:"
        error << projects.map { |project| "- #{Paint[project.name, :magenta]}" }.join("\n")
        raise RundeckError.new(error.join("\n"))
      end
      projects.first
    end

    def self.normalize_name(name)
      name.downcase.gsub(/[^a-z0-9]+/, "")
    end
  end
end
