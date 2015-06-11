_ = require "underscore"


class DetailMixin
  bindings: {}
  autoBind: (name) -> "[data-" + name + "]"

  initialize: (options) ->
    @listenTo @model, "change", @handleModelUpdate
    @listenTo @, "render:post", @bindAttributes

  handleModelUpdate: () ->
    @bindAttributes Object.keys @model.changed

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

    el = @$el.find selector

    if el.is ":input"
      if el.is ":checkbox" or el.is ":radio"
        el.prop "checked", @model.get name
        el.on "change", (e) =>
          @model.set name, el.prop "checked"
          # TODO: validate and save?
      else
        el.val @model.get name
        el.on "change", (e) =>
          @model.set name, el.val()
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
