require 'spec_helper'

describe FML::RequiredIfValidation do
  it "does not require an answer if the parent field is false" do
    form = getform("parent_false.yaml")
    form.fill({"root" => "no"})
    expect(form.fields["requiredifroot"].value).to eq nil
  end

  it "does not allow an empty text field if the parent is true" do
    form = getform("parent_false.yaml")
    params = {"root" => "yes", "requiredifroot" => ""}
    expect {form.fill(params).validate}.to raise_exception FML::ValidationErrors
  end

  it "does allow any nonempty text field value if the parent is true" do
    values = ["something", "!!!", "_"]
    values.each do |value|
      form = getform("parent_false.yaml")
      params = {"root" => "yes", "requiredifroot" => value}
      form.fill(params)
      expect(form.fields["requiredifroot"].value).to eq value
    end
  end

  it "does negative assertions" do
    form = getform("negative_assertion.yaml")
    params = {"root" => "no", "requiredifroot" => ""}
    expect {form.fill(params).validate}.to raise_exception FML::ValidationErrors

    values = ["something", "!!!", "_"]
    values.each do |value|
      form = getform("negative_assertion.yaml")
      params = {"root" => "yes", "requiredifroot" => value}
      form.fill(params)
      expect(form.fields["requiredifroot"].value).to eq value
    end
  end
end
