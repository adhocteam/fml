require 'mustache'

module DTTForms
  class HamlAdapter
    def initialize(form, template_dir=nil)
      @form = form
      if template_dir.nil?
        template_dir = File.join(File.dirname(__FILE__), "haml_templates")
      end

      # In your template dir, there should be a template for "header" and
      # for each form type. They should all end with .haml.mustache
      @@templates = {}
      Dir.glob(File.join(template_dir, "*.haml.mustache")) do |file|
        @@templates[File.basename(file)[0..-15]] = File.read(file)
      end
    end

    def render
      out = Mustache.render(@@templates["header"], :title => @form.title)
      @form.fieldsets.each do |fieldset|
        fieldset.each do |field|
          out += Mustache.render(@@templates[field.type], field.to_h)
        end
      end
      out
    end
  end
end
