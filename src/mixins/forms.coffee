forms = require("forms")
Backbone = require("backbone")
_ = require "underscore"


class FormMixin
  form: null

  events:
    "submit form": "handleFormSubmit"

  initialize: (options={}) ->
    if options.form
      @form = options.form
    if options.renderFunc
      @renderFunc = options.renderFunc

  getContext: (context={}) ->
    if not context.form
      context.form = @renderForm(context)

  getForm: (context) ->
    return @form

  renderForm: (context={}) ->
    form = @getForm(context)
    if @renderFunc
      html = form.toHTML(@renderFunc.bind(@))
    else
      html = form.toHTML()
    return html

  handleFormSubmit: (e) ->
    e.preventDefault()

    data = {}
    for row in  @$(e.target).serializeArray()
      data[row.name] = row.value
    form = @getForm().bind(data)

    form.validate (err, form) =>
      if form.isValid()
        @trigger("form:valid", form)
        @formValid? form
      else
        @trigger("form:invalid", form)
        @formInvalid? form

  formInvalid: (form) ->
    @render(form: form)


bootstrapField = (name, object) ->
  object.widget.classes = object.widget.classes or []
  object.widget.classes.push('form-control')

  inputSize = @inputSize or "col-md-6"
  labelSize = @labelSize or "col-md-6"

  label = object.labelHTML(name)
  label = "<label class='#{labelSize} control-label'>" + label + "</label>"
  if object.error
    error = '<div class="alert alert-error help-block">' +
      object.error + '</div>'
  else
    error = ''

  validationclass = object.value and not object.error and 'has-success' or ''
  validationclass = object.error and 'has-error' or validationclass

  widget = object.widget.toHTML(name, object)
  widget = "<div class='#{inputSize}'>" + widget + "</div>"
  return '<div class="form-group ' + validationclass + '">' +
    label + widget + error + '</div>'


class BootstrapFormMixin extends FormMixin
  renderFunc: bootstrapField
  formInvalid: (form) ->

    @$el.find(".help-block").remove()

    for name, field of form.fields
      input = @$el.find("[name=#{name}]")
      if field.error
        input.after(
          "<span class=\"help-block\">#{field.error}</span>"
        )
        input.parents(".form-group").addClass("has-error")
      else
        input.parents(".form-group").removeClass("has-error")



module.exports =
  mixins:
    FormMixin: FormMixin
    BootstrapFormMixin: BootstrapFormMixin
