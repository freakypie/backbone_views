
Backbone = require("backbone")
_ = require("underscore")
$ = require "jquery"


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

  getContext: (context={}) ->

    if @model
      context.model = @model
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
      # console.log context
      @setElement @template context
    @trigger "render:post"
    return this


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
      @setElement(html)
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
