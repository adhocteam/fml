require 'spec_helper'

describe FML::Field do
  let(:params) {{
    name: "test_field",
    type: "integer",
    label: "test field",
    prompt: "Do you test field?",
    required: true,
    helptext: "Select yes if you test field",
    value: "123"
  }}

  subject { FML::IntegerField.new(params) }

  it "initializes the number" do
    expect(subject.value).to eq "123"
  end

  it "initializes the other fields too" do
    expect(subject.name).to eq "test_field"
    expect(subject.label).to eq "test field"
  end

  it "validates" do
    expect(subject.validate).to eq 123
  end

  context "with an empty value" do
    subject { FML::IntegerField.new(params.merge(value: "")) }

    it "gets nil for an empty string" do
      expect(subject.value).to eq nil
    end

    it "validates" do
      expect(subject.validate).to eq nil
    end
  end

  context "with a float instead of an integer" do
    subject { FML::IntegerField.new(params.merge(value: "12.54")) }

    it "saves the value" do
      expect(subject.value).to eq "12.54"
    end

    it "does not validate" do
      expect { subject.validate }.to raise_error(FML::ValidationError, "Invalid integer \"12.54\"\n")
    end
  end

  context "with a random string" do
    subject { FML::IntegerField.new(params.merge(value: "the beegees")) }

    it "saves the value" do
      expect(subject.value).to eq "the beegees"
    end

    it "does not validate" do
      expect { subject.validate }.to raise_error(FML::ValidationError, "Invalid integer \"the beegees\"\n")
    end
  end
end
