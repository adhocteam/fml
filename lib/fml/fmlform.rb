module FML
  class FMLForm
    attr_reader :form, :title, :version, :fieldsets, :fields

    def initialize(form)
      @fields = {}
      parse(YAML.load(form))
    end

    def fill(params)
      params.each do |field, value|
        if @fields.has_key? field
          @fields[field].value = params[field]
        end
      end
      self
    end

    def to_json
      #TODO: turn an FMLForm into a json doc
      form = {
        form: {
          title: @title,
          version: @version,
          fieldsets: []
        }
      }
      @fieldsets.each do |fieldset|
        fields = []
        fieldset.each do |field|
          fields << {field: field.to_h}
        end
        form[:form][:fieldsets] << {fieldset: fields}
      end
      form.to_json
    end

    # Turn a json form into yaml and return an FMLForm instance
    def self.from_json(json)
      FMLForm.new(JSON.parse(json).to_yaml)
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
      @fields[name.to_sym] = field
    end

    def getrequired(obj, attr)
      begin
        x = obj[attr]
        if x.nil?
          raise KeyError.new("Could not find required `#{attr}` attribute in #{obj}")
        end
      # bare except sucks, but this has raised at least: NoMethodError and TypeError.
      # I wish there were documentation on what errors could be raised so that I
      # could except only those ones
      rescue
        raise KeyError.new("Could not find required `#{attr}` attribute in #{obj}")
      end
      x
    end
  end
end
