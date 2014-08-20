require 'spec_helper'

describe FML::DateField do
  it "accepts a date and converts it" do
    f = FML::DateField.new({"format" => "%m/%d/%y"})
    f.value = '09/22/1982'
    expect(f.value).to eq '09/22/1982'
    expect(f.date.iso8601).to eq '1982-09-22'
  end

  it "validates a date" do
    f = FML::DateField.new({})

    invalid_dates = [["invalid date", "\"invalid date\""], ["1982-09-22", "\"1982-09-22\""]]
    invalid_dates.each do |date, err|
      f = FML::DateField.new({})
      f.value = date
      expect {f.validate}.to raise_exception FML::ValidationError

      begin
        f = FML::DateField.new({})
        f.value = date
        f.validate
      rescue FML::ValidationError => e
        expect(e.message).to eq "Invalid date, must match format %m/%d/%Y\n"
        expect(e.debug_message).to eq "Invalid date #{err} for field nil, expected format \"%m/%d/%Y\"\n"
      end
    end
  end

  it "doesn't throw on validate when date is nil" do
    f = FML::DateField.new({})
    f.value = ""

    expect(f.value).to eq nil
    f.validate
  end

  it "allows invalid dates before validation" do
    invalid_dates = ["This is an invalid date", ""]
    invalid_dates.each do |invalid|
      f = FML::DateField.new({})
      f.value = invalid

      expect(f.date).to eq nil

      # "" -> nil, so this is the only exception
      if invalid == ""
        expect(f.value).to eq nil
      else
        expect(f.value).to eq invalid
      end
    end
  end

  it "handles custom formats" do
    tests = [
      ["%d.%m.%Y", "22.09.1950"],
      ["%Y-%m-%d", "1950-09-22"],
      ["%m/%d/%Y", "09/22/1950"],
      ["%d%b%Y", "22sep1950"],
    ]

    tests.each do |format, date|
      f = FML::DateField.new({format: format})
      f.value = date

      expect(f.date.iso8601).to eq "1950-09-22"
    end
  end
end
