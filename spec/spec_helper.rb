# encoding: utf-8

require "bundler"
Bundler.setup

require "ttfunk"
require "rspec"
require "fakeweb"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/extensions/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  config.include PathHelpers
end
