require 'dttforms'

describe "HAML generation" do
  it "creates a HAML from a DTTForm" do
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

    f = DTTForms::DTTForm.new(form)

    h = DTTForms::HamlAdapter.new(f)
    output = h.render
    expected = <<-eof
.row
  .h1
    = Diabetes mellitus evaluation
  .row
    .small-12.columns
      = f.label :hasDiabetes, "bananarama"
  .row
    .small-12.columns
      = f.radio_button :hasDiabetes, false, text: "No"
      No
  .row
    .small-12.columns
      = f.radio_button :hasDiabetes, true, text: "Yes"
      Yes
eof
    expect(output).to eq expected
  end
end
