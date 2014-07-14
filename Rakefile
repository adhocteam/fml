require "bundler/gem_tasks"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :deploy do
  sh "rm fml*.gem" do |ok, res|
    # ignore errors
    if ! ok; end
  end
  sh "gem build fml.gemspec"
  sh "gem inabox fml*.gem"
end
