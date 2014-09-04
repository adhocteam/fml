module FML
  class XsdAdapter
    def initialize(formspec)
      @formspec = formspec
    end

    def render
      doc = XML::Document.new
      root = node("xs:schema", attrs: {"xmlns:xs" => "http://www.w3.org/2001/XMLSchema"})
      doc.root = root

      calc = node("xs:attribute", attrs: {"name" => "ratingCalculator", "type" => "xs:string"}, parent: root)
      evaln = node("xs:element", attrs: {"name" => "Evaluation"}, parent: root)
      ctype = node("xs:complexType", parent: evaln)
      seq = node("xs:sequence", parent: ctype)
      title = node("xs:element", attrs: {"name" => "title", "type" => "xs:string"}, parent: seq)
      version = node("xs:element", attrs: {"name" => "version", "type" => "xs:string"}, parent: seq)

      @formspec.fields.values.map {|field| _render(field)}.compact
                             .each {|elt| seq << elt}

      return root
    end

    private

    def node(name, value:"", attrs:{}, parent:nil)
      n = XML::Node.new(name, value.to_s)

      attrs.each do |attr, val|
        n.attributes[attr.to_s] = val
      end

      # append the node to its parent if it has one
      if parent
        parent << n
      end

      n
    end

    def ratingCalculatorSpec(name, type)
      elt   = node("xs:element", attrs: {"name" => name, "minOccurs" => "0", "maxOccurs" => "unbounded"})
      ctype = node("xs:complexType", parent: elt)
      sc    = node("xs:simpleContent", parent: ctype)
      ext   = node("xs:extension", attrs: {"base" => "xs:#{type}"}, parent: sc)
      att   = node("xs:attribute", attrs: {"ref" => "ratingCalculator"}, parent: ext)
      return elt
    end

    def _render(field)
      if ["select", "radio"].include?(field.type)
        options = field.options.reject {|x| !x.has_key? "ratingCalculator"}
        if !options.empty?
          return ratingCalculatorSpec(field.name, "boolean")
        end
      elsif ["yes_no", "boolean"].include?(field.type) && field.attrs.has_key?("ratingCalculator")
        return ratingCalculatorSpec(field.name, "boolean")
      elsif field.type == "number" && field.attrs.has_key?("ratingCalculator")
        return ratingCalculatorSpec(field.name, "float")
      end

      nil
    end
  end
end
