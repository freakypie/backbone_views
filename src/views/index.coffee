
Backbone = require("backbone")
_ = require("underscore")


class MixinView extends Backbone.View
  base_mixins: []
  mixins: []

  initialize: (options={}) ->
    @options = options
    if @options.mixins
      @mixins = options.mixins

    for mixin in @listMixins()
      if mixin
        _.defaults(@, mixin)
        mixin.initialize?.apply(@, [options])

        if mixin.events
          @events = _.defaults(@events or {}, mixin.events)
      else
        console.error "Mixin is not valid", mixin

    @trigger("mixins:loaded", @)

  listMixins: () ->
    if not @_mixins
      @_mixins = []
      for m in @base_mixins.concat @mixins
        if m
          @_mixins.push m.prototype
        else
          console.error "Mixin is invalid"
    return @_mixins

  render: () ->
    super()
    @trigger "render:post"


###
  provides a "getContext" function that sends a "view:context" signal
  and calls the "getContext" function of all other mixins
###
class ContextMixin
  _skipContext: true

  getContext: (context={}) ->

    if @model
      context.model = @model.attributes

    if @collection
      context.collection = @collection

    for mixin in @listMixins()
      if not mixin._skipContext
        mixin.getContext?.bind(@)(context)

    # we assume that this is mixed into a view or Backbone.Events
    @trigger("view:context", context)

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

  initialize: (options) ->
    if options.template
      @template = options.template

  getTemplate: () ->
    return @template

  renderNunjucksTemplate: (context={}) ->
    template = @getTemplate()

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
  base_mixins: [NunjucksMixin, ContextMixin, SelectorMixin]

  render: (context={}) ->
    @getContext(context)
    @renderNunjucksTemplate(context)
    @setupUI()
    super(context)
    return @


module.exports =
  mixins:
    ContextMixin: ContextMixin
    NunjucksMixin: NunjucksMixin
    SelectorMixin: SelectorMixin
  views:
    MixinView: MixinView
    NunjucksView: NunjucksView
