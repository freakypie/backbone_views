_ = require "underscore"


class DetailMixin
  bindings: {}
  detailSelector: null
  autoBind: (name) -> "[data-" + name + "]"
  dataActions:
    "toggle": (opts) ->
      if opts.value
        opts.el.show()
      else
        opts.el.hide()
    "inverse-toggle": (opts) ->
      if opts.value
        opts.el.hide()
      else
        opts.el.show()
    "pluralize": (opts) ->
      parseFloat(opts.value) == 1 and opts.el.hide() or opts.el.show()
    "data": (opts) ->
      opts.el.data(opts.name, opts.value)
    "default": (opts) ->
      el = opts.el
      name = opts.name
      if el.is ":input"
        type = el.attr "type"
        if type == "checkbox" or type == "radio"
          el.prop "checked", opts.value
          el.on "change click", (e) =>
            data = {}
            data[name] = el.prop("checked")
            @model.set data
        else
          el.val opts.value
          el.on "change", (e) =>
            data = {}
            data[name] = el.val()
            @model.set data
      else if el.is "img"
        el.attr "src", opts.value
      else
        el.html opts.value

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

    @getSubPanel().find(selector).each (idx, e) =>
      el = @.$(e)
      action = el.attr("data-#{name}") or "default"
      func = @dataActions[action]
      opts = {el: el, name: name, value: @model.get(name)}
      if func
        func.bind(@)(opts)
      else
        @dataActions["default"].bind(@)(opts)


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
