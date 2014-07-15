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

  it "throws a TemplateMissing error when it can't find a template" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))
    f = FML::FMLForm.new(form)

    adapter = FML::HamlAdapter.new(f, template_dir="/")
    expect {adapter.render}.to raise_error(FML::TemplateMissing)
    expect {adapter.render_show}.to raise_error(FML::TemplateMissing)

    begin
      adapter.render
    rescue FML::TemplateMissing => e
      expect(e.message).to eq 'Unable to find template "header" in template list {}'
    end
  end

  it "throws an InvalidTemplate error if it finds an invalid template" do
    datadir = File.join(File.dirname(__FILE__), "data")
    form = File.read(File.join(datadir, "simple.yaml"))
    f = FML::FMLForm.new(form)

    expect {
      FML::HamlAdapter.new(f, template_dir=File.join(datadir, "invalidhaml"))
    }.to raise_error(FML::InvalidTemplate)

    begin
      FML::HamlAdapter.new(f, template_dir=File.join(datadir, "invalidhaml"))
    rescue FML::InvalidTemplate => e
      expect(e.message).to match "Unable to parse file due to Haml syntax error:"
      # the file name changes on different computers, so just test the end of the second line
      expect(e.message).to match ".+:1: Illegal nesting: nesting within plain text is illegal."
    end
  end
end
