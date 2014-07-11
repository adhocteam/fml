require 'yaml'

module FML
  class FMLField
    attr_reader :name, :type, :label, :prompt, :required, :options,
      :conditional_on, :validations

    def initialize(name, type, label, prompt, required, options, conditional_on,
                  validations)
      @name = name
      @type = type
      @label = label
      @prompt = prompt
      @required = required
      @options = options
      @conditional_on = conditional_on
      @validations = validations
    end

    def to_h
      {name: @name,
       type: @type,
       label: @label,
       prompt: @prompt,
       required: @required,
       options: @options,
       conditional_on: @conditional_on,
       validations: @validations,
      }
    end
  end

  class FMLForm
    attr_reader :form, :title, :fieldsets

    def initialize(form)
      parse(YAML.load(form))
    end

    def self.get_spec(conn, specid)
      FMLForm.new(conn.get_spec(specid)[3])
    end

    private

    def parse(yaml)
      @form = getrequired(yaml, "form")
      @title = getrequired(@form, "title")

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

      FMLField.new(name, type, label, prompt, is_required, options, conditional,
                   validations)
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
