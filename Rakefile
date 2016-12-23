require "bundler"
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: [:rubocop, :spec]

desc "Run all rspec files"
RSpec::Core::RakeTask.new("spec")

RuboCop::RakeTask.new
