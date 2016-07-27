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
    "href": (opts) ->
      opts.el.attr("href", opts.value)
    "attr": (opts) ->
      opts.el.attr(opts.args[0], opts.value)
    "prop": (opts) ->
      opts.el.prop(opts.args[0], opts.value)
    "prop-inverse": (opts) ->
      opts.el.prop(opts.args[0], not opts.value)
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
    # clear subpanel
    @subpanel = undefined

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
      args = action.split(":")
      action = args[0]
      args = args[1..]
      func = @dataActions[action]
      opts = {el: el, name: name, value: @model.get(name), args: args}
      if func
        func.bind(@)(opts)
      else
        @dataActions["default"].bind(@)(opts)


class SingleObjectMixin
  fetch: true

  initialize: (options) ->
    if not @model
      if not options.id and not @filters
        console.error "No model id or model filters found on this view", options
        return

      if not @collection
        console.error "No collection found on this view"
        console.error "options", options
        return

      if @id
        @filters = {id: @id}

      @model = @collection.findWhere(@filters)

      if not @model
        @model = new @collection.model
        @model.set(@filters)

        if @fetch
          @model.fetch
            success: =>
              @trigger "view:model", @model
              @handleModelFetched(@model)

          @collection.add @model
        else
          @listenTo @collection, "update", =>
            model = @collection.findWhere(@filters)
            if model
              this.model.set(model.attributes)


  handleModelFetched: (model) ->
    @render()


module.exports =
  mixins:
    DetailMixin: DetailMixin
    SingleObjectMixin: SingleObjectMixin
  # views:
