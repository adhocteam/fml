require 'fml_forms'
require 'byebug'

def getdata(name)
  File.read(File.join(File.dirname(__FILE__), "data", name))
end

def getform(name)
  FML::FMLForm.new(getdata(name))
end
