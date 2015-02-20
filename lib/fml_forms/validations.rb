module FML
  # Validations classes have two required methods:
  #
  #   initialize(field, data, form)
  #     create the validation. `field` is the FMLField object representing
  #     the field in which the validation was created. `data` is the value
  #     given to in the FML spec. `form` is the FMLForm within which the field
  #     was created.
  #
  #   Given a spec like:
  #    form:
  #      title: "Validation Example"
  #      version: "1"
  #      fieldsets:
  #        - fieldset:
  #          - field:
  #              name: "validate"
  #              fieldType: "text"
  #              label: "Dependent"
  #              validations:
  #                - minLength: 10
  #
  #   `field` would be the object represting the `validate` field, `data` would
  #   be 10, and form would be the object representing the entire form spec.
  #
  #   validate()
  #     validate that the condition the validation represents is true. Raises
  #     an FML::ValidationError if it's not, otherwise may return anything
  #
  #  conforms!()
  #    ensure that the validation is applied to the appropriate type of field.
  #    raises FML::InvalidSpec  if it's not, otherwise may return anything
  #
  #  required?()
  #    return true if the condition the validation depends on is satisfied
  #
  # ideas: GreaterThan, LessThan, EarlierThan, LaterThan

  class BaseValidation
    attr_accessor :field, :parent, :form

    def conforms!
    end
  end

  class RequiredIfBoolean < BaseValidation
    def initialize(field, data, form)
      @form = form
      @negative = data.start_with? "!"
      # If the assertion is negative, we require the parent to be true, and
      # vice versa
      @required = !@negative

      # strip the ! if there was one
      data = data[1..-1] if @negative

      @field = field
      @parent = form.fields[data]
    end

    def conforms!
      if ["yes_no", "checkbox"].index(@parent.type).nil?
        raise InvalidSpec.new(<<-EOM)
Field #{@field.name} depends on field #{@parent.name}, which is not a boolean.
Fields may only depend on "yes_no" or "checkbox" fields, but #{@parent.name} is a
"#{@parent.type}" field.
        EOM
      end
    end

    def required?
      @parent.visible? && (@parent.value) == @required
    end

    def valid?
      !(required? && @field.empty?)
    end

    def validate
      # if parent is @required, child must be non-empty. Note that @parent is
      # required to be a boolean element, so we don't need to worry about ""
      # being a truthy value
      if not valid?
        debug_message = <<-EOM
Field #{@field.name}:#{@field.value.inspect} must be present when #{@parent.name}:#{@parent.value.inspect} is #{@required}
        EOM
        user_message = "This field is required"
        err = DependencyError.new(user_message, debug_message, @field.name, @parent.name)
        @field.errors << err
        raise err
      end
    end
  end

  class RequiredIfTextEquals < BaseValidation
    def initialize(field, data, form)
      @field = field
      @wanted_values = Array(data['value'] || data['values'])
      @parent = form.fields[data['field']]
    end

    def conforms!
      if ["select", "text"].index(@parent.type).nil?
        raise InvalidSpec.new(<<-EOM)
Field #{@field.name} depends on field #{@parent.name}, which is not a boolean.
Fields may only depend on "select" or "text" fields, but #{@parent.name} is a
"#{@parent.type}" field.
        EOM
      end
    end

    def required?
      @wanted_values.include?(@parent.value)
    end

    def valid?
      !(required? && @field.empty?)
    end

    def validate
      if not valid?
        debug_message = <<-EOM
Field #{@field.name}:#{@field.value.inspect} must be #{@wanted_values}
        EOM
        user_message = "when #{@parent.name} is '#{@wanted_values}', #{@field.name} must be filled in"
        err = ValidationError.new(user_message, debug_message, @field.name)
        @field.errors << err
        raise err
      end
    end
  end

  class MinLengthValidation < BaseValidation
    def initialize(field, data, form)
      @field = field
      @minlength = data
    end

    def required?
      false
    end

    def valid?
      # @field must be either nil or have length >= minLength
      @field.value.nil? || @field.value.length >= @minlength
    end

    def validate
      if not valid?
        debug_message = <<-EOM
Field #{@field.name}:#{@field.value.inspect} must be longer than #{@minlength} characters
        EOM
        user_message = "Must be longer than #{@minlength} characters"
        err = ValidationError.new(user_message, debug_message, @field.name)
        @field.errors << err
        raise err
      end
    end
  end
end
