module FML
  class FMLField
    attr_reader :name, :type, :label, :prompt, :required, :options,
      :conditional_on, :validations

    attr_accessor :value, :errors

    def initialize(name, type, label, prompt, required, options, conditional_on,
                  validations, value)
      @name = name
      @type = type
      @label = label
      @prompt = prompt
      self.required = required
      @options = options
      @conditional_on = conditional_on
      @validations = validations
      self.value = value
      @errors = []
    end

    def value=(value)
      # Convert value to boolean if a checkbox or yes_no field and value is
      # non-nil
      if !value.nil?
        if @type == "checkbox" || @type == "yes_no"
          if ["1", "true", "yes", true].index(value).nil?
            value = false
          else
            value = true
          end
        elsif @type == "date"
        end
      end

      @value = value
    end

    def required=(value)
      # set @required to a boolean value
      #
      # anything falsy -> false
      # "false" in any case -> false
      # anything else -> true
      if !value || (value.is_a?(String) && value.downcase == "false")
        @required = false
      else
        @required = true
      end
    end

    def to_h
      h = {
        name: @name,
        fieldType: @type,
        label: @label
      }

      h[:prompt] = @prompt if @prompt
      h[:isRequired] = @required if @required
      h[:options] = @options if @options
      h[:conditionalOn] = @conditional_on if @conditional_on
      h[:validations] = @validations if @validations
      h[:value] = @value if @value

      h
    end

    def inspect; self.to_h.to_s end
    def to_s; self.to_h.to_s end
  end

  class DateField<FMLField
    attr_accessor :date

    def initialize(name, type, label, prompt, required, options, conditional_on,
                  validations, value, format)
      # defaults to month/day/year (American style)
      @format = format || "%m/%d/%Y"
      @date = nil

      super(name, type, label, prompt, required, options, conditional_on,
                  validations, value)
    end

    def to_h
      h = {
        name: @name,
        fieldType: @type,
        label: @label
      }

      h[:prompt] = @prompt if @prompt
      h[:isRequired] = @required if @required
      h[:options] = @options if @options
      h[:conditionalOn] = @conditional_on if @conditional_on
      h[:validations] = @validations if @validations
      h[:value] = @value if @value

      h
    end

    def value=(value)
      # Date fields are text fields, so "" -> nil
      if !value || value == ""
        @value = nil
      else
        # we want to save the value even if it doesn't parse; we still need
        # to fill it in for the user
        @value = value

        begin
          @date = Date.strptime value, @format
        rescue ArgumentError
          raise ValidationError.new(<<-EOM, @name)
Invalid date #{value.inspect} for field #{@name.inspect}, expected format #{@format.inspect}
          EOM
        end
      end
    end
  end
end
