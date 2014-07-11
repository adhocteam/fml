require 'fml'

describe "Basic form handling" do
  it "creates a form from a FML spec" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = FML::FMLForm.new(form)
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

  it "gets a form spec from the DB" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))
    row = ["1", "form title", "1.0", form, Time.now, Time.now]
    conn = double(FML::Connection, :get_spec => row)
    f = FML::FMLForm.get_spec(conn, 1234)

    expect(f.title).to eq "Diabetes mellitus evaluation"
    expect(f.form).to eq YAML.load(form)["form"]
    expect(f.fieldsets.length).to eq 1
    expect(f.fieldsets[0].length).to eq 1
  end

  it "raises an IndexError if the spec wasn't found" do
    conn = double(FML::Connection)
    allow(conn).to receive(:get_spec).and_raise(IndexError.new("error"))

    expect { FML::FMLForm.get_spec(conn, 1234) }.to raise_exception IndexError
  end
end
