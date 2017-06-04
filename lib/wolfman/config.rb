module Wolfman
  class Config
    PATH = "#{Dir.home}/.wolfmanrc"

    def self.config!
      if !File.file?(PATH)
        puts "CReating #{PATH}"
        File.open(PATH, "w") { |f| f.write({}.to_yaml) }
      end
      YAML.load_file(PATH)
    end

    def self.get(*keys)
      config!.dig(*keys.map(&:to_s))
    end

    def self.get!(*keys)
      get(*keys) or raise KeyError.new("Config not found: #{keys.join(' => ')}")
    end

    def self.save!(key, value)
      new_config = config!
      new_config[key] = value
      File.write(PATH, new_config.deep_stringify_keys.to_yaml)
    end
  end
end
