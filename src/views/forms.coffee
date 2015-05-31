index = require("./index")
forms = require("forms")
Backbone = require("backbone")
_ = require "underscore"


class FormMixin
  form: null

  events:
    "form submit": "handleFormSubmit"

  initialize: (options={}) ->
    if options.form
      @form = options.form
    if options.renderFunc
      @renderFunc = options.renderFunc

  getContext: (context={}) ->
    context.form = @renderForm(context)

  getForm: (context) ->
    return @form

  renderForm: (context={}) ->
    form = @getForm(context)
    html = form.toHTML(@renderFunc)
    return html

  handleFormSubmit: (e) ->
    data = {}
    for row in  @$(e.target).serializeArray()
      data[row.name] = row.value
    form = @getForm(context).bind(data)

    form.validate (err, form) =>
      if form.isValid()
        @trigger("form:valid", form)
        @formValid? form
      else
        @trigger("form:invalid", form)
        @formInvalid? form

class BootstrapFormMixin extends FormMixin

  bootstrapField: (name, object) ->
    object.widget.classes = object.widget.classes or []
    object.widget.classes.push('form-control')

    inputSize = @inputSize or "col-md-4"
    labelSize = @labelSize or "col-md-8"

    label = object.labelHTML(name)
    label = "<div class='#{labelSize}'>" + label + "</div>"
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


module.exports =
  mixins:
    FormMixin: FormMixin
    BootstrapFormMixin: BootstrapFormMixin
