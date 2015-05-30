
Backbone = require("backbone")
_ = require("underscore")


class MixinView extends Backbone.View
  mixins: []

  initialize: (options={}) ->
    @options = options
    if @options.mixins
      @mixins = options.mixins

    for mixin in @mixins
      _.defaults(@, mixin.prototype)
      mixin.prototype.initialize?.apply(@, [options])

      if mixin.prototype.events
        @events = _.defaults(@events or {}, mixin.prototype.events)

    @trigger("mixins:loaded", @)


###
  provides a "getContext" function that sends a "view:context" signal
  and calls the "getContext" function of all other mixins
###
class ContextMixin

  getContext: (context={}) ->

    # we assume that this is mixed into a view or Backbone.Events
    @trigger("view:context", context)

    if @mixins
      for mixin in @mixins
        mixin.getContext?.bind(@)(context)

    return context


###
selects items on the property `ui`
###
class SelectorMixin

  initialize: (options) ->
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
