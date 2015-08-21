require 'spec_helper'

describe FML::Field do
  subject { FML::Field.new(
    name: "test_field",
    type: "yes_no",
    label: "test field",
    prompt: "Do you test field?",
    required: true,
    helptext: "Select yes if you test field",
  )}

  it "returns everything in to_h" do
    h = subject.to_h
    expect(h[:name]).to eq subject.name
    expect(h[:fieldType]).to eq subject.type
    expect(h[:label]).to eq subject.label
    expect(h[:prompt]).to eq subject.prompt
    expect(h[:isRequired]).to eq subject.required
    expect(h[:helptext]).to eq subject.helptext
  end
end
