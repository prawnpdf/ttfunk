# frozen_string_literal: true

require 'ttfunk'
require 'rspec'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/extensions/ and its subdirectories.
Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.include PathHelpers
  config.include TextHelpers
end
