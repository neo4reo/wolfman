module Wolfman
  class CircleCI
    class CircleCIError < StandardError
    end

    REQUIRED_CONFIG = %w[api_token username]

    def self.configured?
      REQUIRED_CONFIG.all? do |key|
        Config.exists?(:circleci, key)
      end
    end

    def self.recent_builds!(reponame, branch)
      project = CircleCi::Project.new(Config.get!(:circleci, :username), reponame)
      response = with_auth { project.recent_builds_branch(branch) }
      if response.code == "404"
        raise CircleCIError.new("Error: CircleCI project #{Paint[reponame, :magenta]} not found.")
      end
      response.body.map { |build| Resource.new(build) }
    end

    def self.check_auth!
      with_auth { CircleCi::User.new.me }
      true
    end

    def self.with_auth(&block)
      configure!
      response = yield
      if response.code == "401"
        raise CircleCIError.new("Unable to connect. Check that your CircleCI API token is still valid.")
      end
      response
    end

    def self.configure!(token: nil)
      return if @configured
      CircleCi.configure do |config|
        config.token = token || Config.get!(:circleci, :api_token)
      end
      @configured = true
    end
  end
end
