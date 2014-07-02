require 'yaml'

class DTTForm
  attr_reader :form, :title, :fieldsets

  def initialize(form)
    yaml = YAML.load(form)
    @form = getrequired(yaml, "form")
    @title = getrequired(@form, "title")
    @fieldsets = getrequired(@form, "fieldsets")
    #TODO make fieldset objs
  end

  private

  def getrequired(obj, attr)
    x = obj[attr]
    if x.nil?
      raise KeyError.new("Could not find required `#{attr}` attribute in #{obj}")
    end
    x
  end
end
