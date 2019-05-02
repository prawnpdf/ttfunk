# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: %i[rubocop spec]

desc 'Run all rspec files'
RSpec::Core::RakeTask.new('spec')

RuboCop::RakeTask.new

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.options = ['--output-dir', 'doc/html']
end
task docs: :yard
