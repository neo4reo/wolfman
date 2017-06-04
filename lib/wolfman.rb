require "active_support"
require "active_support/core_ext"
require "cri"
require "faraday"
require "json"
require "launchy"
require "netrc"
require "paint"
require "recursive-open-struct"
require "rundeck"

require "wolfman/version"
require "wolfman/config"
# Always require this before any commands:
require "wolfman/cli"
# Require all commands
Dir[File.dirname(__FILE__) + '/wolfman/commands/*.rb'].each {|file| require file }

module Wolfman
end
