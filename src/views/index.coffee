
Backbone = require("backbone")
_ = require("underscore")


class MixinView extends Backbone.View
  mixins: []

  initialize: (options={}) ->
    @options = options
    if @options.mixins
      @mixins = options.mixins

    for mixin in @mixins
      _.extend(@, mixin.prototype)
      mixin.prototype.mixin?.apply(@, [options])


###
selects items on the property `ui`
###
class SelectorMixin

  mixin: (options) ->
    if options.ui
      @ui = options.ui

    if @ui
      # copy the selectors
      # when the template is rendered again
      # we will still have the selectors
      if not @_ui
        @_ui = _.clone @ui

  setupUI: () ->
    if @_ui
      for name, selector of @_ui
        @ui[name] = @$el.find(selector)


###
Renders a nunjucks tempalte
You can set the template on the class or pass it to the constructor
###
class NunjucksMixin

  mixin: (options) ->
    if options.template
      @template = options.template

  renderNunjucksTemplate: (context={}) ->
    if @getTemplate
      template = @getTemplate()
    else
      template = @template

    if not template.compiled
      template.compile()

    if @getContext
      context = @getContext context

    html = template.render context
    @setElement(html)

    return this

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


###
Renders a nunjucks tempalte
You can set the template on the class or pass it to the constructor
###
class NunjucksView extends MixinView
  mixins: [NunjucksMixin, SelectorMixin]

  render: (context={}) ->
    @renderNunjucksTemplate(context)
    @setupUI()
    return this


module.exports =
  mixins:
    NunjucksMixin: NunjucksMixin
    SelectorMixin: SelectorMixin
  views:
    MixinView: MixinView
    NunjucksView: NunjucksView
