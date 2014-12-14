require 'spec_helper'

describe FML::RequiredIfTextEquals do
  context "text fields" do
    it "does not require an answer if the parent field doesn't match a given option" do
      form = getform("text_validation.yaml")
      form.fill({"root" => "James"})
      expect(form.fields["requiredifroot"].value).to eq nil
    end

    it "does not allow an empty text field if the parent matches a single value" do
      form = getform("text_validation.yaml")
      params = {"root" => "Bob", "requiredifroot" => ""}
      expect {form.fill(params).validate}.to raise_exception FML::ValidationErrors
    end
  end

  context "select boxes" do
    it "does not require an answer if the parent field doesn't matches one of the given values" do
      form = getform("text_validation.yaml")
      params = {"sampleSelect" => "2", "requiredifsampleselect" => ""}
      expect(form.fields["requiredifsampleselect"].value).to eq nil
    end

    it "does not allow an empty text field if the parent matches one of the given values" do
      form = getform("text_validation.yaml")
      ["1", "3"].each do |value|
        params = {"sampleSelect" => "3", "requiredifsampleselect" => ""}
        expect {form.fill(params).validate}.to raise_exception FML::ValidationErrors
      end
    end
  end

end
