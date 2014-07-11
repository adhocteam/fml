require 'fml'

describe "HAML generation" do
  it "creates a HAML from a FMLForm" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = FML::FMLForm.new(form)

    h = FML::HamlAdapter.new(f)
    output = h.render()
    expected = File.read(File.join(File.dirname(__FILE__), "data", "simple.html"))
    expect(output).to eq expected
  end
end
