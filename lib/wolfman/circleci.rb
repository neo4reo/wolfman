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
      configure!
      project = CircleCi::Project.new(Config.get!(:circleci, :username), reponame)
      response = project.recent_builds_branch(branch)
      if !response.success?
        if response.code == "404"
          raise CircleCIError.new("Error: CircleCI project #{Paint[reponame, :magenta]} not found.")
        else
          raise CircleCIError.new("Unable to connect. Check that your CircleCI API token is still valid.")
        end
      end
      response.body.map { |build| Resource.new(build) }
    end

    def self.check_authentication!
      configure!
      response = CircleCi::User.new.me
      if !response.success?
        raise CircleCIError.new("Unable to connect. Check that your CircleCI API token is still valid.")
      end
      true
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
