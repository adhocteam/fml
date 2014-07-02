require 'dttforms'

describe "HAML generation" do
  it "creates a HAML from a DTTForm" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = DTTForms::DTTForm.new(form)

    h = DTTForms::HamlAdapter.new(f)
    output = h.render
    expected = File.read(File.join(File.dirname(__FILE__), "data", "simple.haml"))
    expect(output).to eq expected
  end
end
