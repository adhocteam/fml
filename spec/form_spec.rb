require 'fml'

describe "Basic form handling" do
  it "creates a form from a FML spec" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = FML::FMLForm.new(form)
    expect(f.title).to eq "Diabetes mellitus evaluation"
    expect(f.form).to eq YAML.load(form)["form"]
    expect(f.version).to eq "1.0"
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 1

    field = f.fieldsets[0][0]
    expect(field.name).to eq "hasDiabetes"
    expect(field.type).to eq "yes_no"
    expect(field.label).to eq "bananarama"
    expect(field.required).to eq true
  end

  it "can fill in a form" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = FML::FMLForm.new(form)
    params = {hasDiabetes: "true"}
    f.fill(params)
    expect(f.fieldsets[0][0].value).to eq "true"
  end
end
