module Wolfman
  class Config
    CONFIG = YAML.load_file("./config.yml").stringify_keys

    def self.get(*keys)
      CONFIG.dig(*keys.map(&:to_s))
    end
  end
end
