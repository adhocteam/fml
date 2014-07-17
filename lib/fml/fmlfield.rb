module FML
  class FMLField
    attr_reader :name, :type, :label, :prompt, :required, :options,
      :conditional_on, :validations

    attr_accessor :value

    def initialize(name, type, label, prompt, required, options, conditional_on,
                  validations, value)
      @name = name
      @type = type
      @label = label
      @prompt = prompt
      @required = required
      @options = options
      @conditional_on = conditional_on
      @validations = validations
      self.value = value
    end

    def value=(value)
      # Convert value to boolean if a checkbox or yes_no field and value is
      # non-nil
      #
      # XXX: convert this to a strategy pattern if we start having more custom
      #      data conversion for different types
      if value.nil? || ["checkbox", "yes_no"].index(@type).nil?
        @value = value
      else
        if ["1", "true", "yes", true].index(value).nil?
          @value = false
        else
          @value = true
        end
      end
    end

    def to_h
      {name: @name,
       fieldType: @type,
       label: @label,
       prompt: @prompt,
       isRequired: @required,
       options: @options,
       conditionalOn: @conditional_on,
       validations: @validations,
       value: @value,
      }
    end

    def inspect; self.to_h.to_s end
    def to_s; self.to_h.to_s end
  end
end
