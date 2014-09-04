require 'spec_helper'
require 'xml'

describe FML::XsdAdapter do
  it "renders an FML doc into XSD" do
    f = getform("simple.yaml")

    xsd = FML::XsdAdapter.new(f).render()
    schema = XML::Schema.from_string(xsd.to_s)
    instance = XML::Document.file('spec/data/simple.xml')
    instance.validate_schema(schema)
  end

  it "renders diabetes XSD properly" do
    f = getform("diabetes.yaml")

    xsd = FML::XsdAdapter.new(f).render()
    schema = XML::Schema.from_string(xsd.to_s)
    # TODO generate a diabetes XML
    #instance = XML::Document.file('spec/data/simple.xml')
    #instance.validate_schema(schema)
  end
end
