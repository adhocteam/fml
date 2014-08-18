require 'spec_helper'

describe FML::PartialDateField do
  it "takes a YAML value hash" do
    f = FML::PartialDateField.new({})
    value = "month: 8\nyear: 2012\nunknown: false"
    f.value = value

    expect(f.value).to eq value
    expect(f.day).to eq nil
    expect(f.month).to eq 8
    expect(f.year).to eq 2012
    expect(f.unknown).to eq false
  end

  it "ignores invalid yaml" do
    f = FML::PartialDateField.new({})
    value = "- - *2lksj"
    f.value = value

    expect(f.value).to eq value
    expect(f.day).to eq nil
  end
end
