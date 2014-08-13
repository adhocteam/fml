require 'spec_helper'

describe FML::HamlAdapter do
  it "renders an FMLForm into form fields" do
    f = getform("simple.yaml")

    output = FML::HamlAdapter.new(f).render()
    expected = getdata("simple.html")
    expect(expected).to eq output
  end

  it "renders an FMLForm into a show page" do
    f = getform("simple.yaml")

    output = FML::HamlAdapter.new(f).render_show()
    expected = getdata("simple_show.html")
    expect(expected).to eq output
  end

  it "throws a TemplateMissing error when it can't find a template" do
    field = double("field")
    allow(field).to receive(:type) { "bananas" }

    spec = double("spec")
    allow(spec).to receive(:title) { "bananas" }
    allow(spec).to receive(:fieldsets) { [[field]] }

    expect {FML::HamlAdapter.new(spec).render()}.to raise_exception FML::TemplateMissing
  end

  it "throws an InvalidTemplate error if it finds an invalid template" do
    f = getform("simple.yaml")
    invalidhaml = File.join(File.dirname(__FILE__), "data", "invalidhaml")

    expect {
      FML::HamlAdapter.new(f, template_dir=invalidhaml)
    }.to raise_error(FML::InvalidTemplate)

    begin
      FML::HamlAdapter.new(f, template_dir=invalidhaml)
    rescue FML::InvalidTemplate => e
      expect(e.message).to match "Unable to parse file due to Haml syntax error:"
      # the file name changes on different computers, so just test the end of the second line
      expect(e.message).to match ".+:1: Illegal nesting: nesting within plain text is illegal."
    end
  end

  it "correctly uses a view context" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))
    f = FML::FMLForm.new(form)

    class Context
      def image_path
        return "supercalifrajalistic"
      end
    end
    adapter = FML::HamlAdapter.new(f, File.join(File.dirname(__FILE__), "data", "context_test"))
    output = adapter.render(Context.new)
    expect(output).to match /supercalifrajalistic/

    output = adapter.render_show(Context.new)
    expect(output).to match /supercalifrajalistic/
  end
end
