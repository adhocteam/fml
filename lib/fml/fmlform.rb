require 'yaml'

module FML
  class FMLForm
    attr_reader :form, :title, :version, :fieldsets, :fields

    def initialize(form)
      @fields = {}
      parse(YAML.load(form))
    end

    def fill(params)
      params.each do |field|
        if @fields.has? field
          @fields[field].value = params[field]
        end
      end
    end

    def to_json
      #TODO: turn an FMLForm into a json doc
    end

    private

    def parse(yaml)
      @form = getrequired(yaml, "form")
      @title = getrequired(@form, "title")
      @version = getrequired(@form, "version")

      # @fieldsets is just a list of lists of fields
      @fieldsets = getrequired(@form, "fieldsets").collect do |fieldset|
        getrequired(fieldset, "fieldset").collect do |field|
          parsefield(field["field"])
        end
      end
    end

    def parsefield(field)
      name = getrequired(field, "name")
      type = getrequired(field, "fieldType")
      label = getrequired(field, "label")
      prompt = field["prompt"]
      is_required = field["isRequired"]

      #TODO: actually handle the things below this point
      options = field["options"]
      conditional = field["conditionalOn"]
      validations = field["validations"]

      field = FMLField.new(name, type, label, prompt, is_required, options,
                           conditional, validations)
      @fields[name.to_s] = field
    end

    def getrequired(obj, attr)
      x = obj[attr]
      if x.nil?
        raise KeyError.new("Could not find required `#{attr}` attribute in #{obj}")
      end
      x
    end
  end
end
