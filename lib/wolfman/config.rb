module Wolfman
  class Config
    extend SingleForwardable

    DEFAULT_PATH = "#{Dir.home}/.wolfmanrc"
    # Prevent other users from reading/writing to this file.
    PERMISSIONS = 0600

    attr_accessor :path, :attributes
    def_delegators :config, :attributes, :get, :get!, :save!, :exists?

    def initialize(path)
      @path = path
      if !File.file?(path)
        File.open(path, "w") { |f| f.write({}.to_yaml) }
        File.chmod(PERMISSIONS, path)
      end
      @attributes = YAML.load_file(path)
    end

    def get(*keys)
      attributes.dig(*keys.map(&:to_s))
    end

    def get!(*keys)
      get(*keys) or raise KeyError.new("Config not found: #{keys.join(' => ')}")
    end

    def exists?(*keys)
      get(*keys).present?
    end

    def save!(key, value)
      attributes[key] = value
      attributes.deep_stringify_keys!
      File.write(path, attributes.to_yaml)
    end

    def self.config(path = DEFAULT_PATH, reset: false)
      if reset
        @config = nil
        File.delete(path) if File.file?(path)
      end
      @config ||= Config.new(path)
    end
  end
end
