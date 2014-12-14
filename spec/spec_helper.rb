require 'fml_forms'
require 'byebug'

# Add coverage reporting
require 'simplecov'
SimpleCov.start

def getdata(name)
  File.read(File.join(File.dirname(__FILE__), "data", name))
end

def getform(name)
  FML::Form.new(getdata(name))
end

RSpec.configure do |config|
# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
