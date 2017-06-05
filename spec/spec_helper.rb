require "bundler/setup"
require "wolfman"
require "rspec/collection_matchers"
require "webmock/rspec"
require "rspec/its"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.before do
    # Override config path for specs, reset config between tests.
    config_path = File.join(File.expand_path(File.dirname(__FILE__)), ".wolfmanrc")
    Wolfman::Config.config(config_path, reset: true)
  end
end
