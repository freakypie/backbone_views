_ = require "underscore"


class DetailMixin
  bindings: {}
  detailSelector: null
  autoBind: (name) -> "[data-" + name + "]"

  initialize: (options) ->
    @listenTo @model, "change", @handleModelUpdate
    @listenTo @, "render:post", @bindAttributes

  handleModelUpdate: () ->
    @bindAttributes Object.keys @model.changed

  getSubPanel: () ->
    if not @subpanel
      if @detailSelector
        @subpanel = @$el.find @detailSelector
      else
        @subpanel = @$el
    return @subpanel

  bindAttributes: (attrs=null) ->
    if not attrs
      if @model?.attributes
        attrs = Object.keys @model.attributes
      else
        attrs = []

    for name in attrs
      @bindAttribute name

  bindAttribute: (name) ->
    selector = @bindings[name]
    if not selector and @autoBind
      selector = @autoBind name

    el = @getSubPanel().find selector

    if el.is ":input"
      type = el.attr "type"
      if type == "checkbox" or type == "radio"
        el.prop "checked", @model.get name
        el.on "change click", (e) =>
          data = {}
          data[name] = el.prop("checked")
          @model.set data
      else
        el.val @model.get name
        el.on "change", (e) =>
          data = {}
          data[name] = el.val()
          @model.set data
    else if el.is "img"
      el.attr "src", @model.get(name)
    else
      e = el
      e.each (idx, e) =>
        el = @.$(e)
        action = el.data(name)
        if action == "toggle"
          if @model.get(name)
            el.show()
          else
            el.hide()
        else if action == "inverse-toggle"
          if @model.get(name)
            el.hide()
          else
            el.show()
        else
          el.html @model.get name


class SingleObjectMixin

  initialize: (options) ->
    if not @model
      if not options.id
        console.error "No model id found on this view"
        return

      if not @collection
        console.error "No collection found on this view"
        console.error "options", options
        return

      @model = @collection.get(options.id)
      if not @model
        @model = new @collection.model
        @model.id = options.id
        @model.fetch
          success: =>
            console.log "fetched model"
            @trigger "view:model", @model
            @handleModelFetched(@model)

        @collection.add @model

  handleModelFetched: (model) ->
    @render()


module.exports =
  mixins:
    DetailMixin: DetailMixin
    SingleObjectMixin: SingleObjectMixin
  # views:
