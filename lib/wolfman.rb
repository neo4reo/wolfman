require "active_support"
require "active_support/core_ext"
require "cri"
require "faraday"
require "faraday-cookie_jar"
require "highline/import"
require "json"
require "launchy"
require "netrc"
require "paint"
require "recursive-open-struct"
require "yaml"

require "wolfman/version"
require "wolfman/cli"
require "wolfman/config"
require "wolfman/rundeck"
Dir[File.dirname(__FILE__) + '/wolfman/commands/*.rb'].each {|file| require file }

module Wolfman
end
