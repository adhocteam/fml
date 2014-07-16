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
      begin
        json = JSON.parse(json)
      rescue JSON::JSONError => e
        raise FML::InvalidSpec.new(<<-EOM)
JSON parser raised an error:
#{e.message}
        EOM
      end
      FMLForm.new(json.to_yaml)
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
      validtypes = ["string", "text", "select", "multi-select", "yes_no", "boolean", "date", "time", "checkbox"]
      if validtypes.index(type).nil?
        raise InvalidSpec.new("Invalid field type #{type} in form field #{field}")
      end

      label = getrequired(field, "label")
      prompt = field["prompt"]
      is_required = field["isRequired"]

      #TODO: actually handle the things below this point
      options = field["options"]
      conditional = field["conditionalOn"]
      validations = field["validations"]
      value = field["value"]

      field = FMLField.new(name, type, label, prompt, is_required, options,
                           conditional, validations, value)

      if @fields.has_key? name
        raise InvalidSpec.new(<<-ERR)
Duplicate field name #{name}.
This field: #{field.to_s}
has the same name as: #{@fields[name].to_s}
        ERR
      end
      @fields[name] = field
    end

    def getrequired(obj, attr)
      begin
        x = obj[attr]
        if x.nil?
          raise InvalidSpec.new("Could not find required `#{attr}` attribute in #{obj}")
        end
      # bare except sucks, but this has raised at least: NoMethodError and TypeError.
      # I wish there were documentation on what errors could be raised so that I
      # could except only those ones
      rescue
        raise InvalidSpec.new("Could not find required `#{attr}` attribute in #{obj}")
      end
      x
    end
  end

  class InvalidSpec<Exception
  end
end
