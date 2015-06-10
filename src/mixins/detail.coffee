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
      attrs = Object.keys @model.attributes

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


module.exports =
  mixins:
    DetailMixin: DetailMixin
  # views:
