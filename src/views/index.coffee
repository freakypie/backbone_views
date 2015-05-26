
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

  setupUi: () ->
    if @_ui
      for name, selector of @_ui
        @ui[name] = @$el.find(selector)
    return this


###
Renders a nunjucks tempalte
You can set the template on the class or pass it to the constructor
###
class NunjucksMixin

  mixin: (options) ->
    if options.template
      @template = options.template

  renderNunjucksTemplate: (context={}) ->
    if not @template.compiled
      @template.compile()

    context = @getContext context

    html = @template.render context
    this.$el.html html

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
