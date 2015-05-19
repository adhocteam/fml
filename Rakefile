require "bundler/gem_tasks"
require 'rspec/core/rake_task'

# require FML
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fml_forms/version'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :test => :spec
