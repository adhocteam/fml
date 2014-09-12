require 'spec_helper'

describe FML::NumberField do
  it "accepts a number and converts it" do
    f = FML::NumberField.new({})
    f.value = '56.23'
    expect(f.value).to eq '56.23'
    expect(f.number).to eq 56.23
  end

  it "validates a number" do
    invalid_numbers = ["bananas", "43,223", "__2__"]
    invalid_numbers.each do |n|
      f = FML::NumberField.new({name: "sampleNumber"})
      f.value = n

      # ensure we keep the value before validation
      expect(f.value).to eq n

      expect {f.validate}.to raise_exception FML::ValidationError

      begin
        f.validate
      rescue FML::ValidationError => e
        expect(e.field_name).to eq "sampleNumber"
        expect(e.message).to eq "Invalid number \"#{n}\"\n"
        expect(e.debug_message).to eq "Invalid number \"#{n}\" for field \"sampleNumber\"\n"
      end
    end
  end

  it "doesn't throw on validate when number is nil" do
    f = FML::NumberField.new({})
    f.value = ""

    expect(f.value).to eq nil
    f.validate
  end
end
