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

def set_valid_config!
  set_valid_aws_config!
  set_valid_circleci_config!
  set_valid_rundeck_config!
end

def set_valid_aws_config!
  Wolfman::Config.save!(:aws, {
    access_key_id: "AKIA123",
    secret_access_key: "secret12345",
    account_id: "mycompany",
    region: "us-east-1",
  })
end

def set_valid_circleci_config!
  Wolfman::Config.save!(:circleci, {
    api_token: "some-token",
    username: "my-github-org",
  })
end

def set_valid_rundeck_config!
  Wolfman::Config.save!(:rundeck, {
    host: "https://rundeck.example.com",
    username: "myuser",
    password: "mypassword",
  })
end

def stub_circleci_response(object, method, body: nil, status: 200)
  stub = allow_any_instance_of(object).to receive(method)
  success = status.to_i < 400
  stub.and_return(double(code: status.to_s, success?: success, body: body))
end
