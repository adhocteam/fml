module FML
  class FMLForm
    attr_reader :form, :title, :version, :fieldsets, :fields

    @@validation_classes = {
      "requiredIf" => FML::RequiredIfValidation,
      "minLength" => FML::MinLengthValidation,
    }

    @@field_classes = {
      "text" => FMLField,
      "select" => FMLField,
      "multi-select" => FMLField,
      "yes_no" => FMLField,
      "date" => DateField,
      "time" => FMLField,
      "checkbox" => FMLField,
      "string" => FMLField,
      "radio" => FMLField
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
            @fields[field].errors << e
            errors << e
          end
        end
      end

      # check required fields
      @fields.each do |name,field|
        if field.required && field.empty?
          debug_msg = "Field #{name.inspect} is required"
          user_msg = "This Field is Required"
          e = ValidationError.new(user_msg, debug_msg, field.name)
          errors << e
          field.errors << e
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
        raise ValidationErrors.new(errors, self)
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
      params = {}
      params[:name] = getrequired(field, "name")

      # names must be valid HTML 4 ids:
      #   ID and NAME tokens must begin with a letter ([A-Za-z]) and may be
      #   followed by any number of letters, digits ([0-9]), hyphens ("-"),
      #   underscores ("_"), colons (":"), and periods (".").
      if params[:name].match(/^[A-Za-z][A-Za-z0-9\-_:\.]*$/).nil?
        raise InvalidSpec.new("Invalid field name #{params[:name].inspect} in form field #{field}")
      end

      params[:type] = getrequired(field, "fieldType")
      validtypes = @@field_classes.keys
      if validtypes.index(params[:type]).nil?
        raise InvalidSpec.new("Invalid field type #{params[:type].inspect} in form field #{field}")
      end

      params[:label] = getrequired(field, "label")
      params[:prompt] = field["prompt"]
      params[:required] = field["isRequired"]

      params[:options] = field["options"]

      # if field is conditional on another field, store the dependency
      params[:conditionalOn] = field["conditionalOn"]
      if !params[:conditionalOn].nil?
        @conditional[params[:conditionalOn]] << params[:name]
      end

      params[:validations] = field["validations"]
      params[:value] = field["value"]
      params[:helptext] = field["helptext"]
      params[:format] = field["format"]

      field = @@field_classes[params[:type]].new(params)

      if @fields.has_key? params[:name]
        raise InvalidSpec.new(<<-ERR)
Duplicate field name #{params[:name]}.
This field: #{field.to_s}
has the same name as: #{@fields[params[:name]].to_s}
        ERR
      end

      @fields[params[:name]] = field
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
    attr :debug_message, :field_name
    def initialize(user_message, debug_message, field_name)
      user_message += "\n" if !user_message.end_with? "\n"
      debug_message += "\n" if !user_message.end_with? "\n"

      super(user_message)
      @debug_message = debug_message
      @field_name = field_name
    end
  end

  class DependencyError<ValidationError
    attr :depends_on
    def initialize(user_message, debug_message, field_name, depends_on)
      @depends_on = depends_on
      super(user_message, debug_message, field_name)
    end
  end

  # a container for ValidationError instances found by #validate
  class ValidationErrors<Exception
    attr :errors, :form

    def initialize(errors, form)
      super(errors.collect{ |e| e.message }.join(""))
      @errors = errors
      @form = form
    end
  end

  class InvalidSpec<Exception
  end
end
