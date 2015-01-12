module FML
  class Form
    attr_reader :form, :title, :version, :fieldsets, :fields, :bodySystem, :dependent

    @@validation_classes = {
      "requiredIf" => FML::RequiredIfBoolean,
      "textEquals" => FML::RequiredIfTextEquals,
      "minLength" => FML::MinLengthValidation,
    }

    @@conditional_classes = {
      "requiredIf" => FML::RequiredIfBoolean,
      "textEquals" => FML::RequiredIfTextEquals
    }

    @@field_classes = {
      "text" => Field,
      "select" => Field,
      "multi-select" => Field,
      "yes_no" => BooleanField,
      "date" => DateField,
      "partialdate" => PartialDateField,
      "time" => Field,
      "checkbox" => BooleanField,
      "string" => Field,
      "radio" => Field,
      "markdown" => MarkdownField,
      "number" => NumberField,
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
      # update each field's value
      params.each do |field, value|
        if @fields.has_key? field
          @fields[field].value = params[field]
        end
      end

      self
    end

    # Validate the form. Returns self if succesful, raises ValidationErrors if
    # not
    def validate
      errors = []

      # check required fields
      @fields.each do |name,field|
        if field.required && field.empty?
          debug_msg = "Field #{name.inspect} is required"
          user_msg = "This Field is Required"
          e = ValidationError.new(user_msg, debug_msg, field.name)
          errors << e
          field.errors << e
        end

        begin
          field.validate
        rescue ValidationError => e
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
          # Validations are responsible for pushing errors into the appropriate field
        end
      end

      if !errors.empty?
        raise ValidationErrors.new(errors, self)
      end

      self
    end

    def to_json
      form = {
        form: {
          title: @title,
          version: @version,
          bodySystem: @bodySystem,
          dependent: @dependent,
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

    # Turn a json form into yaml and return an Form instance
    def self.from_json(json)
      begin
        json = JSON.parse(json)
      rescue JSON::JSONError => e
        raise FML::InvalidSpec.new(<<-EOM)
JSON parser raised an error:
#{e.message}
        EOM
      end
      Form.new(json.to_yaml)
    end

    private

    def parse(yaml)
      @form = getrequired(yaml, "form")
      @title = getrequired(@form, "title")
      @version = getrequired(@form, "version")
      @bodySystem = @form["bodySystem"]
      @dependent = @form["dependent"]

      # @fieldsets is just a list of lists of fields
      @fieldsets = getrequired(@form, "fieldsets").collect do |fieldset|
        getrequired(fieldset, "fieldset").collect do |field|
          parsefield(field)
        end
      end

      # verify that the type of each field that is depended upon
      # is checkbox or yes_no
      @conditional.each do |conditional,dependents|
        dependents.each do |dependent|
          runner = if conditional.is_a?(String)
             "requiredIf"
          else
            if conditional.keys.length > 1
              raise InvalidSpec.new(<<-EOM)
  Fields #{dependents.inspect} can only have one conditionalOn
            EOM
            end
            conditional_type = conditional.keys[0]
            conditional = conditional[conditional_type]
            conditional_type
          end

          if @fields[dependent].required
            raise InvalidSpec.new(<<-EOM)
Conditional field #{dependent.inspect} cannot be required
            EOM
          end

          if !@@conditional_classes.has_key?(runner)
            raise InvalidSpec.new("Invalid conditionalOn Type")
          end

          runner_instance = @@conditional_classes[runner].new(@fields[dependent], conditional, self)

          if runner_instance.parent.nil?
            raise InvalidSpec.new(<<-EOM)
Fields #{dependents.inspect} depend on field #{conditional}, which does not exist
            EOM
          end

          runner_instance.conforms!
          @fields[dependent].conditional_on_runner = runner_instance
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
      # We want to keep the original field untouched for good debugging
      # messages, and we make destructive updates below, so make a deep
      # copy of the field and save the original
      fullfield = field["field"]
      field = YAML.load(YAML.dump(field["field"]))

      params = {}
      params[:name] = poprequired(field, "name")

      # names must be valid HTML 4 ids:
      #   ID and NAME tokens must begin with a letter ([A-Za-z]) and may be
      #   followed by any number of letters, digits ([0-9]), hyphens ("-"),
      #   underscores ("_"), colons (":"), and periods (".").
      if params[:name].match(/^[A-Za-z][A-Za-z0-9\-_:\.]*$/).nil?
        raise InvalidSpec.new("Invalid field name #{params[:name].inspect} in form field #{fullfield}")
      end

      params[:type] = poprequired(field, "fieldType")
      validtypes = @@field_classes.keys
      if validtypes.index(params[:type]).nil?
        raise InvalidSpec.new("Invalid field type #{params[:type].inspect} in form field #{fullfield}")
      end

      params[:label] = poprequired(field, "label")
      params[:prompt] = pop(field, "prompt")
      params[:required] = pop(field, "isRequired")
      params[:format] = pop(field, "format")

      # options must be a list of hashes with at least "name" and "value"
      # keys, whose values must be strings
      params[:options] = pop(field, "options")
      if params[:options]
        if !params[:options].class == Array
          raise InvalidSpec.new("Invalid option value #{params[:options].inspect} in form field #{fullfield}")
        end

        params[:options].each do |option|
          if !option.is_a?(Hash)
            raise InvalidSpec.new("option must be a hash but is type #{option.class} in form field #{fullfield}")
          end
          if !option.has_key?("name") || !option.has_key?("value")
            raise InvalidSpec.new("option hash #{option.inspect} must have 'name' and 'value' keys")
          end
          if !option["name"].is_a?(String) || !option["value"].is_a?(String)
            raise InvalidSpec.new("option name and value must be strings #{option.inspect}")
          end
        end
      end

      # if field is conditional on another field, store the dependency
      params[:conditionalOn] = pop(field, "conditionalOn")
      if !params[:conditionalOn].nil?
        @conditional[params[:conditionalOn]] << params[:name]
      end

      params[:validations] = pop(field, "validations")
      params[:value] = pop(field, "value")
      params[:helptext] = pop(field, "helptext")
      params[:disable] = pop(field, "disable")

      # The remaining kwargs get stuck in the params hash
      params[:attrs] = field

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

    # return attr from hash obj. If it's not present, throw an exception
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

    # pull attr from hash obj and delete it.
    def pop(obj, attr)
      obj.delete(attr)
    end

    def poprequired(obj, attr)
      begin
        x = obj.delete(attr)
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
