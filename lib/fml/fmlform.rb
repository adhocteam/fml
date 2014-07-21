module FML
  class FMLForm
    attr_reader :form, :title, :version, :fieldsets, :fields

    @@validation_classes = {
      "requiredIf" => FML::RequiredIfValidation,
      "minLength" => FML::MinLengthValidation,
    }

    def initialize(form)
      # @fields stores the fields from all fieldsets by name. Helps ensure that
      # we don't reuse names
      @fields = {}

      # @conditional stores the field dependencies. Each key is an array of the
      # fields that depend on it.
      @conditional = Hash.new{|h, k| h[k] = []}

      @validations = []

      begin
        parse(YAML.load(form))
      rescue Psych::SyntaxError => e
        raise FML::InvalidSpec.new(<<-EOM)
Invalid YAML. #{e.line}:#{e.column}:#{e.problem} #{e.context}
        EOM
      end
    end

    # fill ensures that all fields pass their validations and that all
    # dependencies are satisfied.
    #
    # Returns self if successful, throws FML::InvalidSpec if not
    def fill(params)
      errors = []

      # update each field's value
      params.each do |field, value|
        if @fields.has_key? field
          begin
            @fields[field].value = params[field]
          rescue ValidationError => e
            errors << e
          end
        end
      end

      # check required fields
      @fields.each do |name,field|
        if field.required && field.value.nil?
          errors << ValidationError.new(<<-EOM, field.name)
Field #{name.inspect} is required
          EOM
        end
      end

      # run the validations
      @validations.each do |validation|
        begin
          validation.validate
        rescue ValidationError => e
          errors << e
        end
      end

      if !errors.empty?
        raise ValidationErrors.new(errors)
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

      # verify that the type of each field that is depended upon
      # is checkbox or yes_no
      @conditional.each do |conditional,dependents|
        if ["yes_no", "checkbox"].index(@fields[conditional].type).nil?
          raise InvalidSpec.new(<<-EOM)
Fields #{dependents.inspect} depend on field #{conditional}, which is not a boolean.
Fields may only depend on "yes_no" or "checkbox" fields, but #{conditional} is a
#{@fields[conditional].type.inspect} field.
          EOM
        end
      end

      # for each field, if it has validations, create the appropriate class
      @fields.values.reject {|f| f.validations.nil?}.each do |field|
        field.validations.each do |validation|
          # validation is a hash {<<validation>>: <<data>>}. Split it
          validation, data = validation.to_a.first
          if !@@validation_classes.has_key? validation
            raise InvalidSpec.new("No such validation #{validation.inspect}")
          end
          @validations << @@validation_classes[validation].new(field, data, self)
        end
      end
    end

    def parsefield(field)
      name = getrequired(field, "name")

      # names must be valid HTML 4 ids:
      #   ID and NAME tokens must begin with a letter ([A-Za-z]) and may be
      #   followed by any number of letters, digits ([0-9]), hyphens ("-"),
      #   underscores ("_"), colons (":"), and periods (".").
      if name.match(/^[A-Za-z][A-Za-z0-9\-_:\.]*$/).nil?
        raise InvalidSpec.new("Invalid field name #{name.inspect} in form field #{field}")
      end

      type = getrequired(field, "fieldType")
      validtypes = ["string", "text", "select", "multi-select", "yes_no", "date", "time", "checkbox"]
      if validtypes.index(type).nil?
        raise InvalidSpec.new("Invalid field type #{type.inspect} in form field #{field}")
      end

      label = getrequired(field, "label")
      prompt = field["prompt"]
      is_required = field["isRequired"]

      options = field["options"]

      # if field is conditional on another field, store the dependency
      conditional = field["conditionalOn"]
      if !conditional.nil?
        @conditional[conditional] << name
      end

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

  class ValidationError<Exception
    attr :field_name
    def initialize(message, field_name)
      if !message.end_with? "\n"
        message += "\n"
      end

      super(message)
      @field_name = field_name
    end
  end

  class DependencyError<ValidationError
    attr :depends_on
    def initialize(message, field_name, depends_on)
      @depends_on = depends_on
      super(message, field_name)
    end
  end

  # a container for ValidationError instances found by #validate
  class ValidationErrors<Exception
    attr :errors
    def initialize(errors)
      super(errors.collect{ |e| e.message }.join(""))
      @errors = errors
    end
  end

  class InvalidSpec<Exception
  end
end
