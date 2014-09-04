require 'spec_helper'
require 'xml'

describe FML::XmlAdapter do
  it "renders an FML doc into XML" do
    f = getform("simple.yaml")

    xsd = FML::XsdAdapter.new(f).render()
    schema = XML::Schema.from_string(xsd.to_s)

    params = {
      "hasDiabetes" => "yes",
      "sampleCheckbox" => "0",
      "sampleDate" => "01/01/2014",
      "sampleTextarea" => "Rick James",
      "sampleString" => "Lazy brown fox",
      "sampleNumber" => 6.45
    }
    f.fill(params)

    instance = FML::XmlAdapter.new(f).render()
    instance.validate_schema(schema)
  end

  it "renders the diabetes doc into XML" do
    f = getform("diabetes.yaml")

    xsd = FML::XsdAdapter.new(f).render()
    schema = XML::Schema.from_string(xsd.to_s)

    params = {
      "includesStrenuousActivities" => true,
      "frequencyOfKetoacidosisRequiringCareProviderVisits" => "Episodes of ketoacidosis requiring twice a month visits to a diabetic care provider",
    }
    f.fill(params)

    instance = FML::XmlAdapter.new(f).render()
    instance.validate_schema(schema)

    # Since this key is set, the one that's set should be true
    key = "frequencyOfKetoacidosisRequiringCareProviderVisits"
    truenode  = instance.find("/Evaluation/#{key}[@ratingCalculator='#{params[key]}']")
    falsenode = instance.find("/Evaluation/#{key}[@ratingCalculator!='#{params[key]}']")

    expect(truenode.length).to eq 1
    expect(truenode[0].content).to eq "true"
    expect(falsenode.length).to eq 1
    expect(falsenode[0].content).to eq "false"

    # Since this key isn't set, the two nodes should have false values
    key = "frequencyOfHypoglycemiaRequiringCareProviderVisits"
    nodes = instance.find("/Evaluation/#{key}")

    expect(nodes.length).to eq 2
    expect(nodes.map{|x| x.content == "false"}.all?).to eq true
  end

  def find_node_by_name_and_rc(doc, name, ratingCalculator)
    nodes = doc.find("/Evaluation/#{name}")
    nodes.each do |node|
      if node.attributes["ratingCalculator"] == ratingCalculator
        return node
      else
        p node.attributes["ratingCalculator"], ratingCalculator
      end
    end
    nil
  end
end
