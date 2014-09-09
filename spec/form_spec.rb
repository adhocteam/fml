require 'spec_helper'

describe FML::Form do
  it "creates a form from a FML spec" do
    form = getdata("simple.yaml")

    f = FML::Form.new(form)
    expect(f.title).to eq "Simple sample form"
    expect(f.form).to eq YAML.load(form)["form"]
    expect(f.version).to eq "1.0"
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 10

    field = f.fieldsets[0][0]
    expect(field.name).to eq "hasDiabetes"
    expect(field.type).to eq "yes_no"
    expect(field.label).to eq "bananarama"
    expect(field.required).to eq true
    expect(field.attrs["attribute"]).to eq "value"

    field = f.fieldsets[0][1]
    expect(field.name).to eq "sampleCheckbox"
    expect(field.type).to eq "checkbox"
    expect(field.label).to eq "Would you like to check me?"
    expect(field.required).to eq true
    expect(field.conditional_on).to eq "hasDiabetes"

    field = f.fieldsets[0][2]
    expect(field.name).to eq "sampleDate"
    expect(field.type).to eq "date"
    expect(field.label).to eq "Pick any date"

    field = f.fieldsets[0][3]
    expect(field.name).to eq "sampleTextarea"
    expect(field.type).to eq "text"
    expect(field.label).to eq "Enter some text"
    expect(field.required).to eq true
    expect(field.disabled).to eq true

    field = f.fieldsets[0][4]
    expect(field.name).to eq "sampleString"
    expect(field.type).to eq "string"
    expect(field.label).to eq "This is a string"
    expect(field.required).to eq true

    field = f.fieldsets[0][5]
    expect(field.name).to eq "sampleRadio"
    expect(field.type).to eq "radio"
    expect(field.label).to eq "Please select one of the following options"
    expect(field.required).to eq false
    expect(field.options[0]["name"]).to eq "First"
    expect(field.options[0]["value"]).to eq "1"

    field = f.fieldsets[0][6]
    expect(field.name).to eq "sampleSelect"
    expect(field.type).to eq "select"
    expect(field.label).to eq "Please select one of the following options"
    expect(field.required).to eq false
    expect(field.options[1]["name"]).to eq "Second"
    expect(field.options[1]["value"]).to eq "2"

    field = f.fieldsets[0][7]
    expect(field.name).to eq "sampleMarkdown"
    expect(field.type).to eq "markdown"
    expect(field.value).to eq "<p>Something <em>italicized</em></p>\n"

    field = f.fieldsets[0][8]
    expect(field.name).to eq "samplePartialDate"
    expect(field.type).to eq "partialdate"
    expect(field.label).to eq "Partial Date"

    field = f.fieldsets[0][9]
    expect(field.name).to eq "sampleNumber"
    expect(field.type).to eq "number"
    expect(field.label).to eq "Sample Number"
  end

  it "preserves the value" do
    form = getdata("simple.yaml")

    # Add the "value" attribute to hasDiabetes and give it "yes"
    y = YAML.load(form)
    y["form"]["fieldsets"][0]["fieldset"][3]["field"]["value"] = "bananas"

    f = FML::Form.new(y.to_yaml)
    expect(f.fieldsets[0][3].value).to eq "bananas"
  end

  it "preserves the helptext attribute" do
    form = getdata("simple.yaml")

    # Add the "value" attribute to hasDiabetes and give it "yes"
    y = YAML.load(form)
    helptext = <<-EOL
This is a field
where help text can go
it can contain newlines
they will be preserved
    EOL
    y["form"]["fieldsets"][0]["fieldset"][3]["field"]["helptext"] = helptext

    f = FML::Form.new(y.to_yaml)
    expect(f.fieldsets[0][3].helptext).to eq helptext
  end

  it "can fill in a form" do
    params = {
      "hasDiabetes" => "yes",
      "sampleCheckbox" => "0",
      "sampleDate" => "01/01/2014",
      "sampleTextarea" => "Rick James",
      "sampleString" => "Lazy brown fox",
    }
    form = getform("simple.yaml").fill(params)

    expect(form).to be_a(FML::Form)
    expect(form.fieldsets[0][0].value).to eq true
    expect(form.fieldsets[0][1].value).to eq false
    expect(form.fieldsets[0][2].value).to eq "01/01/2014"
    expect(form.fieldsets[0][2].date.iso8601).to eq "2014-01-01"
    expect(form.fieldsets[0][3].value).to eq "Rick James"
    expect(form.fieldsets[0][4].value).to eq "Lazy brown fox"
  end

  it "allows a partial form fill and preserves values" do
    params = {
      "hasDiabetes" => "yes",
      "sampleCheckbox" => "0",
      # these attributes are required. omit them.
      #"sampleDate" => "01/01/2014",
      #"sampleTextarea" => "Rick James",
      #"sampleString" => "Lazy brown fox",
    }
    form = getform("simple.yaml").fill(params)

    expect(form).to be_a(FML::Form)
    expect(form.fieldsets[0][0].value).to eq true
    expect(form.fieldsets[0][1].value).to eq false
    expect(form.fieldsets[0][2].value).to eq nil
    expect(form.fieldsets[0][3].value).to eq nil
    expect(form.fieldsets[0][4].value).to eq nil
  end

  it "properly stores the value of empty text fields" do
    params = {
      "sampleDate" => "",
      "sampleTextarea" => "",
      "sampleString" => "",
    }
    form = getform("simple.yaml").fill(params)

    expect(form).to be_a(FML::Form)
    expect(form.fieldsets[0][2].value).to eq nil
    expect(form.fieldsets[0][3].value).to eq nil
    expect(form.fieldsets[0][4].value).to eq nil
  end

  it "can export itself as json" do
    params = {
      "hasDiabetes" => "yes",
      "sampleCheckbox" => "1",
      "sampleDate" => "01/01/2014",
      "sampleTextarea" => "Rick James",
      "sampleString" => "Lazy brown fox",
    }
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
    expect(field["value"]).to eq true
  end

  it "can load itself from json" do
    params = {
      "hasDiabetes" => "yes",
      "sampleCheckbox" => "1",
      "sampleDate" => "01/01/2014",
      "sampleTextarea" => "Rick James",
      "sampleString" => "Lazy brown fox",
    }
    json = getform("simple.yaml").fill(params).to_json

    f = FML::Form.from_json(json)
    expect(f.title).to eq "Simple sample form"
    expect(f.version).to eq "1.0"
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 10

    field = f.fieldsets[0][0]
    expect(field.name).to eq "hasDiabetes"
    expect(field.type).to eq "yes_no"
    expect(field.label).to eq "bananarama"
    expect(field.required).to eq true

    expect(f.fields["sampleCheckbox"].value).to eq true
  end

  it "raises an InvalidSpec error on invalid json" do
    expect {FML::Form.from_json("{\ninvalid json")}.to raise_exception FML::InvalidSpec

    begin
      FML::Form.from_json("{\ninvalid json")
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "JSON parser raised an error:\n757: unexpected token at '{\ninvalid json'\n"
    end
  end

  it "raises an InvalidSpec error on an invalid field type" do
    expect {getform("invalid_field_type.yaml")}.to raise_exception FML::InvalidSpec

    begin
      getform("invalid_field_type.yaml")
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Invalid field type \"notavalidtype\" in form field {\"name\"=>\"hasDiabetes\", \"fieldType\"=>\"notavalidtype\", \"label\"=>\"bananarama\", \"isRequired\"=>true}"
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
      expect(e.message).to eq "Duplicate field name name.\nThis field: {:name=>\"name\", :fieldType=>\"yes_no\", :label=>\"gooseegg\", :isRequired=>false}\nhas the same name as: {:name=>\"name\", :fieldType=>\"checkbox\", :label=>\"bananarama\", :isRequired=>true}\n"
    end
  end

  it "requires required fields" do
    form = getform("required.yaml")
    params = {
      "notrequired" => "bananas",
    }

    expect {form.fill(params).validate}.to raise_exception FML::ValidationErrors
    begin
      form.fill({})
    rescue FML::ValidationErrors => e
      expect(e.errors.length).to eq 1
      expect(e.message).to eq "This Field is Required\n"
      expect(e.form).to be_a FML::Form
    end
  end

  it "raises InvalidSpec on invalid names" do
    yaml = YAML.load(getdata("simple.yaml"))
    invalid_names = [".something", "_", "Some$thing", "sp ace", "!not legal"]
    invalid_names.each do |name|
      yaml["form"]["fieldsets"][0]["fieldset"][2]["field"]["name"] = name
      expect {FML::Form.new(yaml.to_yaml)}.to raise_exception FML::InvalidSpec
    end

    valid_names = ["Something", "MiXeD", "da-sh", "why.dot", "un_der", "l33t"]
    valid_names.each do |name|
      yaml["form"]["fieldsets"][0]["fieldset"][2]["field"]["name"] = name
      expect(FML::Form.new(yaml.to_yaml)).to be_a FML::Form
    end
  end

  it "raises InvalidSpec on invalid YAML" do
    expect {FML::Form.new('--- `')}.to raise_exception FML::InvalidSpec

    begin
      FML::Form.new('--- `')
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Invalid YAML. 1:5:found character that cannot start any token while scanning for the next token\n"
    end
  end

  it "gives a boolean value to yes_no or checkbox fields" do
    params = {
      "checkbox" => "1",
      "yesno" => "no",
    }

    form = getform("boolean.yaml").fill(params)
    expect(form.fields["checkbox"].value).to eq true
    expect(form.fields["yesno"].value).to eq false
    expect(form.fields["leavemenil"].value).to eq nil
  end

  it "raises an error for fields that are conditional upon non-yes_no or checkbox fields" do
    yaml = YAML.load(getdata("conditional.yaml"))
    yaml["form"]["fieldsets"][0]["fieldset"][0]["field"]["fieldType"] = "text"
    expect {FML::Form.new(yaml.to_yaml)}.to raise_exception FML::InvalidSpec

    begin
      FML::Form.new(yaml.to_yaml)
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Fields [\"DependsOnRoot\"] depend on field RootQ, which is not a boolean.\nFields may only depend on \"yes_no\" or \"checkbox\" fields, but RootQ is a\n\"text\" field.\n"
    end
  end

  it "raises an error for conditionalOn nonexistent field" do
    yaml = YAML.load(getdata("conditional.yaml"))
    yaml["form"]["fieldsets"][0]["fieldset"][0]["field"]["conditionalOn"] = "doesnotexist"
    expect {FML::Form.new(yaml.to_yaml)}.to raise_exception FML::InvalidSpec

    begin
      FML::Form.new(yaml.to_yaml)
    rescue FML::InvalidSpec => e
      expect(e.message).to eq "Fields [\"RootQ\"] depend on field doesnotexist, which does not exist\n"
    end
  end

  it "raises InvalidSpec on an invalid validation name" do
    expect {getform("invalid_validation.yaml")}.to raise_exception FML::InvalidSpec
  end

  it "raises a ValidationErrors when there is a validation error" do
    # expect no errors on valid input, no input
    params = {"root" => "true", "requiredIfRoot" => "something valid"}
    getform("validation.yaml").fill(params)
    getform("validation.yaml").fill({})

    params = {"root" => "true"}
    expect {getform("validation.yaml").fill(params).validate}.to raise_exception FML::ValidationErrors

    begin
      getform("validation.yaml").fill(params).validate
    rescue FML::ValidationErrors => e
      expect(e.message).to eq "This field is required\n"
    end

    params = {"root" => "true", "requiredIfRoot" => "tooshort"}
    expect {getform("validation.yaml").fill(params).validate}.to raise_exception FML::ValidationErrors
    begin
      getform("validation.yaml").fill(params).validate
    rescue FML::ValidationErrors => e
      expect(e.message).to eq "Must be longer than 10 characters\n"
    end

    # We had a bug where the empty string was the value for a blank text field,
    # which therefore passed the requiredIf validation. Ensure that a blank
    # text field does not pass a requiredIf. (validation2.yaml has no minLength
    # validation)
    params = {"root" => "true", "requiredIfRoot" => ""}
    expect {getform("validation2.yaml").fill(params).validate}.to raise_exception FML::ValidationErrors
    begin
      getform("validation2.yaml").fill(params).validate
    rescue FML::ValidationErrors => e
      expect(e.message).to eq "This field is required\n"
    end
  end

  it "should not require a field with isRequired of false" do
    params = {
      "sampleCheckbox" => "1",
      "sampleDate" => "10/10/2014",
      "sampleTextarea" => "Rick James",
      "sampleString" => "Lazy brown fox",
    }
    yaml = YAML.load(getdata("simple.yaml"))
    yaml["form"]["fieldsets"][0]["fieldset"][0]["field"]["isRequired"] = "false"
    json = FML::Form.new(yaml.to_yaml).fill(params).to_json
  end

  it "saves errors in fields" do
    params = {
      "hasDiabetes" => "yes",
      "sampleCheckbox" => "0",
      "sampleDate" => "",
      "sampleTextarea" => "Rick James",
      "sampleString" => "Lazy brown fox",
    }
    begin
      form = getform("simple.yaml")
      form.fill(params)
    rescue FML::ValidationErrors => e
      expect(form.fields["sampleDate"].errors.length).to eq 1
      expect(form.fields["sampleDate"].errors[0]).to be_a FML::ValidationError
    end
  end

  it "accepts 'no' as a valid answer on a required field" do
    form = getform("yes_no.yaml")
    form.fill({"root" => "yes", "requiredifroot" => "no"})
    expect(form.fields["requiredifroot"].value).to eq false
  end
end
