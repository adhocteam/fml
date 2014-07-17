require 'fml'

describe FML::FMLForm do
  it "creates a form from a FML spec" do
    form = getdata("simple.yaml")

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

    field = f.fieldsets[0][1]
    expect(field.name).to eq "sampleCheckbox"
    expect(field.type).to eq "checkbox"
    expect(field.label).to eq "Would you like to check me?"
    expect(field.required).to eq true

    field = f.fieldsets[0][2]
    expect(field.name).to eq "sampleDate"
    expect(field.type).to eq "date"
    expect(field.label).to eq "Pick any date"
    expect(field.required).to eq true

    field = f.fieldsets[0][3]
    expect(field.name).to eq "sampleTextarea"
    expect(field.type).to eq "text"
    expect(field.label).to eq "Enter some text"
    expect(field.required).to eq true
  end

  it "preserves the value" do
    form = getdata("simple.yaml")

    # Add the "value" attribute to hasDiabetes and give it "true"
    y = YAML.load(form)
    y["form"]["fieldsets"][0]["fieldset"][0]["field"]["value"] = "true"

    f = FML::FMLForm.new(y.to_yaml)
    expect(f.fieldsets[0][0].value).to eq "true"
  end

  it "can fill in a form" do
    params = {"hasDiabetes" => "true"}
    form = getform("simple.yaml").fill(params)

    expect(form).to be_a(FML::FMLForm)
    expect(form.fieldsets[0][0].value).to eq "true"
  end

  it "can export itself as json" do
    params = {"hasDiabetes" => "true"}
    json = getform("simple.yaml").fill(params).to_json

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
    params = {"hasDiabetes" => "true"}
    json = getform("simple.yaml").fill(params).to_json

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

  it "raises an InvalidSpec error on invalid json" do
    expect {FML::FMLForm.from_json("{\ninvalid json")}.to raise_exception FML::InvalidSpec

    begin
      FML::FMLForm.from_json("{\ninvalid json")
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "JSON parser raised an error:\n757: unexpected token at '{\ninvalid json'\n"
    end
  end

  it "raises an InvalidSpec error on an invalid field type" do
    expect {getform("invalid_field_type.yaml")}.to raise_exception FML::InvalidSpec

    begin
      getform("invalid_field_type.yaml")
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Invalid field type notavalidtype in form field {\"name\"=>\"hasDiabetes\", \"fieldType\"=>\"notavalidtype\", \"label\"=>\"bananarama\", \"isRequired\"=>true}"
    end
  end

  it "raises an InvalidSpec error on a missing required field" do
    expect {getform("missing_name.yaml")}.to raise_exception FML::InvalidSpec

    begin
      getform("missing_name.yaml")
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Could not find required `name` attribute in {\"fieldType\"=>\"checkbox\", \"label\"=>\"bananarama\", \"isRequired\"=>true}"
    end
  end

  it "raises an error if the spec has a duplicate name" do
    expect {getform("duplicate_name.yaml")}.to raise_exception FML::InvalidSpec

    begin
      getform("duplicate_name.yaml")
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Duplicate field name name.\nThis field: {:name=>\"name\", :fieldType=>\"yes_no\", :label=>\"gooseegg\", :prompt=>nil, :isRequired=>false, :options=>nil, :conditionalOn=>nil, :validations=>nil, :value=>nil}\nhas the same name as: {:name=>\"name\", :fieldType=>\"checkbox\", :label=>\"bananarama\", :prompt=>nil, :isRequired=>true, :options=>nil, :conditionalOn=>nil, :validations=>nil, :value=>nil}\n"
    end
  end

  private

  def getdata(name)
    File.read(File.join(File.dirname(__FILE__), "data", name))
  end

  def getform(name)
    FML::FMLForm.new(getdata(name))
  end
end
