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
end
