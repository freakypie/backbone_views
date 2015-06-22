
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
      for m in @mixins.concat @base_mixins
        if m
          @_mixins.push m.prototype
        else
          console.error "Mixin is invalid"
    return @_mixins

  getContext: (context={}) ->

    if @model
      context.model = @model
      if @model.attributes
        _.extend context, @model.attributes

    if @collection
      context.collection = @collection

    for mixin in @listMixins()
      mixin.getContext?.bind(@)(context)

    # we assume that this is mixed into a view or Backbone.Events
    @trigger("view:context", context)

    return context

  render: (context={}) ->
    @trigger "render:pre"
    context = @getContext context
    if @renderer
      @renderer context
    else if @template
      @$el.html @template context
    @trigger "render:post"
    return this

  remove: () ->
    for mixin in @listMixins()
      if mixin.remove
        mixin.remove.apply(@)
    super()


###
selects items on the property `ui`
###
class SelectorMixin

  initialize: (options) ->
    @listenTo @, "render:post", @setupUI.bind(@)

  setupUI: () ->
    if @.constructor.prototype.ui
      @ui = {}
      for name, selector of @.constructor.prototype.ui
        @ui[name] = @$el.find(selector)


###
Renders a nunjucks tempalte
You can set the template on the class or pass it to the constructor
###
class NunjucksMixin
  templateSetRoot: false

  initialize: (options) ->
    if options.template
      @template = options.template

  getTemplate: () ->
    return @template

  renderer: (context={}) ->
    template = @getTemplate()

    if not template.compiled
      template.compile()

    if @getContext
      context = @getContext context

    html = template.render context
    if @templateSetRoot
      parent = @$el.parent()
      @setElement(html)
      if parent.length > 0
        parent.empty().append(@el)
    else
      @$el.html html
      @delegateEvents()

    return this


module.exports =
  mixins:
    NunjucksMixin: NunjucksMixin
    SelectorMixin: SelectorMixin
  views:
    MixinView: MixinView
