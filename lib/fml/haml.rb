require 'haml'

module FML
  class HamlAdapter
    EMPTY = Object.new

    def initialize(formspec, template_dir=nil)
      @formspec = formspec
      if template_dir.nil?
        template_dir = File.join(File.dirname(__FILE__), "haml_templates")
      end

      # In your template dir, there should be a template for "header" and
      # for each form type. They should all end with .haml
      @@templates = {}
      if @@templates.empty?
        Dir.glob(File.join(template_dir, "*.haml")) do |file|
          begin
            @@templates[File.basename(file)[0..-6]] = Haml::Engine.new(File.read(file))
          rescue Haml::SyntaxError => e
            raise InvalidTemplate.new(<<-ERR, e)
Unable to parse file due to Haml syntax error:
#{file}:#{e.line}: #{e.message}
            ERR
          end
        end
      end
    end

    def render(view_context=EMPTY)
      locals = {formspec: @formspec}
      out = _render("header", locals, view_context)
      @formspec.fieldsets.each do |fieldset|
        fieldset.each do |field|
          locals[:field] = field
          out += _render(field.type, locals, view_context)
        end
      end
      out
    end

    def render_show(view_context=EMPTY)
      locals = {formspec: @formspec}
      out = _render("header_show", locals, view_context)
      @formspec.fieldsets.each do |fieldset|
        fieldset.each do |field|
          locals[:field] = field
          out += _render("#{field.type}_show", locals, view_context)
        end
      end
      out
    end

    private

    def _render(template, locals, view_context=EMPTY)
      if !@@templates.has_key? template
        raise TemplateMissing.new("Unable to find template \"#{template}\" in template list #{@@templates}")
      end
      @@templates[template].render(view_context, locals)
    end
  end

  class TemplateMissing<Exception
  end

  class InvalidTemplate<Exception
    attr_reader :hamlerror
    def initialize(message, hamlerror)
      super(message)
      @hamlerror = hamlerror
    end
  end
end
