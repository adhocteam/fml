# bowling_spec.rb
require 'dttforms'

describe "Basic form handling" do
  it "creates a form from a FML spec" do
    #TODO stick this in a feile
    form = <<-eos
form:
  title: "Diabetes mellitus evaluation"
  fieldsets:
    - fieldset:
      - field:
          name: "hasDiabetes"
          fieldType: "yes_no"
          label: "Does the patient currently have diabetes mellitus?"
          isRequired: true
    eos

    f = DTTForm.new(form)
    expect(f.title).to eq "Diabetes mellitus evaluation"
    expect(f.form).to eq YAML.load(form)["form"]
  end
end
