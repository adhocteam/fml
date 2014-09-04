module FML
  class XmlAdapter
    def initialize(form)
      @form = form
    end

    def render
      doc = XML::Document.new
      root = XML::Node.new("Evaluation")
      doc.root = root
      root << XML::Node.new("title", @form.title)
      root << XML::Node.new("version", @form.version)
      @form.fields.values.map {|field| _render(field)}.compact
                         .each {|elts| elts.each {|elt| root << elt}}
      return doc
    end

    private

    def field(name, ratingCalc, val)
      n = XML::Node.new(name, val.to_s)
      n.attributes["ratingCalculator"] = ratingCalc
      return n
    end

    # return an array of XML nodes representing the field
    def _render(field)
      if ["select", "radio"].include?(field.type)
        options = field.options.reject {|x| !x.has_key? "ratingCalculator"}
        if !options.empty?
          return options.map do |option|
            field(field.name, option["ratingCalculator"], field.value == option["value"])
          end
        end
      elsif ["yes_no", "boolean"].include?(field.type) && field.attrs.has_key?("ratingCalculator")
        # convert nil to a false, else keep the value
        val = field.value.nil? ? false : field.value
        return [field(field.name, field.attrs["ratingCalculator"], val)]
      elsif field.type == "number" && field.attrs.has_key?("ratingCalculator")
        return [field(field.name, field.attrs["ratingCalculator"], field.value)]
      end
      []
    end
  end
end
