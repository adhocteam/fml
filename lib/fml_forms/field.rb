require 'redcarpet'

module FML
  class Field
    attr_reader :name, :type, :label, :prompt, :required, :options,
      :conditional_on, :validations, :helptext, :disabled, :attrs

    attr_accessor :value, :errors

    def initialize(params)
      @name = params[:name]
      @type = params[:type]
      @label = params[:label]
      @prompt = params[:prompt]
      self.required = params[:required]
      @options = params[:options]
      @conditional_on = params[:conditionalOn]
      @validations = params[:validations]
      @helptext = params[:helptext]
      @disabled = params[:disable]
      @attrs = params[:attrs]
      self.value = params[:value]
      @errors = []
    end

    def value=(value)
      # convert empty strings to nil
      if !value || value == ""
        @value = nil
      else
        @value = value
      end
    end

    # raise a ValidationError if there's an invalid value; else do nothing.
    # ignore the return value.
    def validate
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

    def empty?
      @value.nil? || @value == ""
    end

    def to_h
      h = {
        name: @name,
        fieldType: @type,
        label: @label
      }

      h[:prompt] =        @prompt if !@prompt.nil?
      h[:isRequired] =    @required if !@required.nil?
      h[:options] =       @options if !@options.nil?
      h[:conditionalOn] = @conditional_on if !@conditional_on.nil?
      h[:validations] =   @validations if !@validations.nil?
      h[:value] =         @value if !@value.nil?
      h[:attrs] =         @attrs if !@attrs.nil?

      h
    end

    def inspect; self.to_h.to_s end
    def to_s; self.to_h.to_s end

    private

    def to_bool(value)
      if !value.nil?
        if ["1", "true", "yes", "on", true].index(value).nil?
          value = false
        else
          value = true
        end
      end

      value
    end
  end

  class BooleanField<Field
    def value=(value)
      @value = to_bool(value)
    end
  end

  class NumberField<Field
    attr_accessor :number

    def initialize(params)
      @number = nil

      super(params)
    end

    def value=(value)
      # Number fields are text fields, so "" -> nil
      if !value || value == ""
        @value = nil
      else
        # we want to save the value even if it doesn't parse; we still need
        # to fill it in for the user
        @value = value

        begin
          @number = Float(value)
        rescue ArgumentError
          # Try to generate the date object but ignore failures here; we raise
          # them in the validate step
        end
      end
    end

    def validate
      if @value
        begin
          @number = Float(@value)
        rescue ArgumentError, TypeError
          debug_message = <<-EOM
Invalid number #{@value.inspect} for field #{@name.inspect}
          EOM
          user_message = "Invalid number #{@value.inspect}"
          raise ValidationError.new(user_message, debug_message, @name)
        end
      end
    end
  end

  class DateField<Field
    attr_accessor :date

    def initialize(params)
      # defaults to month/day/year (American style)
      @format = params[:format] || "%m/%d/%Y"
      @date = nil

      super(params)
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
          # Try to generate the date object but ignore failures here; we raise
          # them in the validate step
        end
      end
    end

    def validate
      if @value
        begin
          @date = Date.strptime @value, @format
        rescue ArgumentError, TypeError
          debug_message = <<-EOM
Invalid date #{@value.inspect} for field #{@name.inspect}, expected format #{@format.inspect}
          EOM
          user_message = "Invalid date, must match format #{@format}"
          raise ValidationError.new(user_message, debug_message, @name)
        end
      end
    end
  end

  class PartialDateField<Field
    attr :day, :month, :year, :unknown, :estimate

    # The value attribute of a PartialDateField is a YAML string with five
    # optional keys: "day", "month", "year", "unknown", and "estimate"
    def value=(value)
      # Date fields are text fields, so "" -> nil
      if !value || value == ""
        @value = nil
      else
        @value = value

        begin
          y = YAML.load(value)
          @day      = y["day"]
          @month    = y["month"]
          @year     = y["year"]
          @unknown  = to_bool(y["unknown"])
          @estimate = to_bool(y["estimate"])
        rescue
          # ignore any invalid YAML and continue processing. I wish I could
          # handle only the exceptions that YAML.load could throw, but there
          # are many
        end
      end
    end

    def empty?
      [@day, @month, @year, @unknown, @estimate].map {|x| !x || x == ""}.all?
    end
  end

  class MarkdownField<Field
    def initialize(params)
      # XXX: these are just the default params given in the docs, not sure
      # which options we really want
      @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
      super(params)
    end

    def value=(value)
      if !value || value == ""
        @value = nil
      else
        @value = @markdown.render(value)
      end
    end
  end
end
