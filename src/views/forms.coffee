index = require("./index")
forms = require("forms")
Backbone = require("backbone")

class FormMixin
  form: null

  initialize: (options={}) ->
    if options.form
      @form = options.form
    if options.renderFunc
      @renderFunc = options.renderFunc

  getForm: (context) ->
    return @form

  renderForm: (context={}) ->
    form = @getForm(context)
    html = form.toHTML(renderFunc)
    @$el.html html


class FormView extends index.views.MixinView
  mixins: [SelectorMixin, FormMixin]

  render: (context={}) ->
    @renderForm(context)
    @setupUI()
    return this


module.exports =
  mixins:
    FormMixin: FormMixin
  views:
    FormView: FormView
