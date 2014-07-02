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
          label: "bananarama"
          isRequired: true
    eos

    f = DTTForm.new(form)
    expect(f.title).to eq "Diabetes mellitus evaluation"
    expect(f.form).to eq YAML.load(form)["form"]
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 1

    field = f.fieldsets[0][0]
    expect(field.name).to eq "hasDiabetes"
    expect(field.type).to eq "yes_no"
    expect(field.label).to eq "bananarama"
    expect(field.required).to eq true
  end
end
