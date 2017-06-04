module Wolfman
  class AWS
    REQUIRED_CONFIG = %w[account_id access_key_id secret_access_key region]
    class AWSError < StandardError
    end

    def self.configured?
      REQUIRED_CONFIG.all? do |key|
        Config.exists?(:aws, key)
      end
    end

    def self.find_instances!(env, service)
      service = normalize_name(service)
      results = ec2_client.describe_instances(
        filters: [
          {name: "instance-state-name", values: ["running"]},
          {name: "tag:Environment", values: [env]}
        ],
      )
      instances = results.map do |result|
        result.reservations.map(&:instances)
      end.flatten
      filtered_instances = instances.select do |instance|
        name = instance_name(instance)
        name.present? && normalize_name(name).include?(service)
      end
      if filtered_instances.empty?
        raise AWSError.new("Unable to find instances with a tag matching #{Paint[service, :magenta]}.")
      end
      filtered_instances
    end

    def self.instance_name(instance)
      find_tag(instance, "service")&.value
    end

    def self.find_tag(instance, key)
      instance.tags.find { |tag| tag.key.downcase == key.downcase }
    end

    def self.find_environment!(env)
      normalized_env = normalize_name(env)
      normalized_env = "prod" if normalized_env == "production"
      environment = environments.find do |environment|
        normalize_name(environment).include?(normalized_env)
      end
      if !environment.present?
        raise AWSError.new("Unable to find environment #{Paint[env, :magenta]}.\nValid options are #{Paint[environments.join(", "), :magenta]}.")
      end
      environment
    end

    def self.environments
      @environments ||= ec2_client.describe_tags(
        filters: [
          {name: "key", values: ["Environment"]},
        ],
      ).tags.map(&:value).uniq
    end

    def self.ec2_client
      configure!
      @ec2_client ||= Aws::EC2::Client.new
    end

    def self.configure!
      return if @configuration_set
      Aws.config.update({
        credentials: Aws::Credentials.new(
          Config.get!(:aws, :access_key_id),
          Config.get!(:aws, :secret_access_key)
        ),
        region: Config.get!(:aws, :region),
      })
      @configuration_set = true
    end

    def self.normalize_name(name)
      name.downcase.gsub(/[^a-z0-9]+/, "")
    end
  end
end
