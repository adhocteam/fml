require 'haml'

module FML
  class HamlAdapter
    def initialize(formspec, template_dir=nil)
      @formspec = formspec
      if template_dir.nil?
        template_dir = File.join(File.dirname(__FILE__), "haml_templates")
      end

      # In your template dir, there should be a template for "header" and
      # for each form type. They should all end with .haml
      @@templates = {}
      Dir.glob(File.join(template_dir, "*.haml")) do |file|
        @@templates[File.basename(file)[0..-6]] = Haml::Engine.new(File.read(file))
      end
    end

    def render()
      o = Object.new
      locals = {formspec: @formspec}
      out = @@templates["header"].render(o, locals)
      @formspec.fieldsets.each do |fieldset|
        fieldset.each do |field|
          locals[:field] = field
          out += @@templates[field.type].render(o, locals)
        end
      end
      out
    end
  end
end