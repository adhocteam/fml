require 'fml'

describe FML::FMLForm do
  it "creates a form from a FML spec" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = FML::FMLForm.new(form)
    expect(f.title).to eq "Simple sample form"
    expect(f.form).to eq YAML.load(form)["form"]
    expect(f.version).to eq "1.0"
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 4

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
    form = f.fill(params)
    expect(f.fieldsets[0][0].value).to eq "true"
    expect(form).to be_a(FML::FMLForm)
  end

  it "can export itself as json" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = FML::FMLForm.new(form)
    params = {hasDiabetes: "true"}
    form = f.fill(params)
    json = form.to_json

    expect(json).to be_a(String)
    obj = JSON.parse(json)
    expect(obj["form"]["title"]).to eq "Simple sample form"
    expect(obj["form"]["version"]).to eq "1.0"
    expect(obj["form"]["fieldsets"].length).to eq 1
    expect(obj["form"]["fieldsets"][0].length).to eq 1

    field = obj["form"]["fieldsets"][0]["fieldset"][0]["field"]
    expect(field["name"]).to eq "hasDiabetes"
    expect(field["fieldType"]).to eq "yes_no"
    expect(field["label"]).to eq "bananarama"
    expect(field["isRequired"]).to eq true
    expect(field["value"]).to eq "true"
  end

  it "can load itself from json" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    params = {hasDiabetes: "true"}
    form = FML::FMLForm.new(form).fill(params)
    json = form.to_json

    f = FML::FMLForm.from_json(json)
    expect(f.title).to eq "Simple sample form"
    expect(f.version).to eq "1.0"
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 4

    field = f.fieldsets[0][0]
    expect(field.name).to eq "hasDiabetes"
    expect(field.type).to eq "yes_no"
    expect(field.label).to eq "bananarama"
    expect(field.required).to eq true
  end
end
