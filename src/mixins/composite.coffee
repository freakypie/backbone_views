_ = require "underscore"


class CompositeMixin
  compositeSelector: ".views"
  views: {}

  initialize: (options) ->
    @listenTo @, "render:post", @renderViews

  getViewOptions: (name) ->
    return {}

  createView: (name, klass) ->
    options = @getViewOptions name
    return new @klass(options)

  renderViews: () ->
    composite = @$el.find @compositeSelector
    for name, klass of @views
      composite.append(@createView(name, klass))


module.exports =
  mixins:
    Composite: CompositeMixin
  # views:
