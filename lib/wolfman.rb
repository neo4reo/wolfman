require "active_support"
require "active_support/core_ext"
require "faraday"
require "json"
require "launchy"
require "netrc"
require "recursive-open-struct"
require "rundeck"

require "wolfman/version"
require "wolfman/config"
Dir[File.dirname(__FILE__) + '/wolfman/commands/*.rb'].each {|file| require file }

# Always require this last, after all commands have been loaded:
require "wolfman/cli"

module Wolfman
end
