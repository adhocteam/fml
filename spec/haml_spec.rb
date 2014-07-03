require 'dttforms'

class Formmock
  def label(name, label)
    "<label for=\"#{name}\">#{label}</label>"
  end
  def radio_button(name, val, options)
    "<input type=\"radio\">#{val}</input>"
  end
end

describe "HAML generation" do
  it "creates a HAML from a DTTForm" do
    form = File.read(File.join(File.dirname(__FILE__), "data", "simple.yaml"))

    f = DTTForms::DTTForm.new(form)

    h = DTTForms::HamlAdapter.new(f)
    output = h.render(Formmock.new)
    expected = File.read(File.join(File.dirname(__FILE__), "data", "simple.haml"))
    expect(output).to eq expected
  end
end
