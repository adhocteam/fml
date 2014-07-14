require 'fml'

describe FML::HamlAdapter do
  it "renders an FMLForm into form fields" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))
    f = FML::FMLForm.new(form)

    output = FML::HamlAdapter.new(f).render()
    expected = File.read(File.join(File.dirname(__FILE__), "data", "simple.html"))
    expect(output).to eq expected
  end

  it "renders an FMLForm into a show page" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))
    f = FML::FMLForm.new(form)

    output = FML::HamlAdapter.new(f).render_show()
    expected = File.read(File.join(File.dirname(__FILE__), "data", "simple_show.html"))
    expect(output).to eq expected
  end
end
