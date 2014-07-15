module FML
  class FMLField
    attr_reader :name, :type, :label, :prompt, :required, :options,
      :conditional_on, :validations

    attr_accessor :value

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

      # If a field gets filled in, it sets value to a value. It may remain nil.
      @value = nil
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
