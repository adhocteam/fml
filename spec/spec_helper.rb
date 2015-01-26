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
