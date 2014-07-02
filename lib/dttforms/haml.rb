require 'mustache'

module DTTForms
  class HamlAdapter
    @@templates = {
      header: <<-eos
.row
  .h1
    = {{ title }}
    eos,

      yes_no: <<-eos
  .row
    .small-12.columns
      = f.label :{{ name }}, "{{ label }}"
  .row
    .small-12.columns
      = f.radio_button :{{ name }}, false, text: "No"
      No
  .row
    .small-12.columns
      = f.radio_button :{{ name }}, true, text: "Yes"
      Yes
    eos
    }

    def initialize(form)
      @form = form
    end

    def render
      out = Mustache.render(@@templates[:header], :title => @form.title)
      @form.fieldsets.each do |fieldset|
        fieldset.each do |field|
          out += Mustache.render(@@templates[field.type], field.to_h)
        end
      end
      out
    end
  end
end
