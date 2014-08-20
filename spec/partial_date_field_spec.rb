require 'spec_helper'

describe FML::PartialDateField do
  it "takes a YAML value hash" do
    tests = [
      ["---\nday: '22'\nmonth: '8'\nyear: '2012'\nunknown: \nestimate: 'on'",
       ['22', '8', '2012', nil, true]],
      ["---\nyear: '2012'\nunknown: 'on'\nestimate: ",
       [nil, nil, '2012', true, nil]],
    ]

    tests.each do |test, expected|
      f = FML::PartialDateField.new({})
      f.value = test

      day, month, year, unknown, estimate = expected

      expect(f.value).to eq test
      expect(f.day).to eq day
      expect(f.year).to eq year
      expect(f.unknown).to eq unknown
      expect(f.estimate).to eq estimate
    end
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
