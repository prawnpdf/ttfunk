# encoding: utf-8

require "ttfunk"
require "rspec"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/extensions/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.include PathHelpers
end
