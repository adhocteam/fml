require 'spec_helper'

describe FML::PartialDateField do
  it "takes a YAML value hash" do
    f = FML::PartialDateField.new({})
    value = "---\nmonth: '8'\nyear: '2012'\nunknown: \nestimate: 'on'"
    f.value = value

    expect(f.value).to eq value
    expect(f.day).to eq nil
    expect(f.month).to eq '8'
    expect(f.year).to eq '2012'
    expect(f.unknown).to eq nil
    expect(f.estimate).to eq true
  end

  it "ignores invalid yaml" do
    f = FML::PartialDateField.new({})
    value = "- - *2lksj"
    f.value = value

    expect(f.value).to eq value
    expect(f.day).to eq nil
  end

  it "handles empty properly" do
    values = [
      ["---\nmonth: ''\nyear: ''\nunknown: ", true],
      ["---\nmonth: '8'\nyear: ''\nunknown: ", false],
      ["---\nmonth: ''\nyear: ''\nunknown: 'true'", false],
    ]
    values.each do |test, expected|
      f = FML::PartialDateField.new({})
      f.value = test

      expect(f.empty?).to eq expected
    end
  end
end
