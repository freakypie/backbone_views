_ = require "underscore"

class Composite
  views: {}
  compost: {}

  initialize: (options) ->
    @listenTo @, "render:post", @renderViews

  createView: (options) ->
    return new options.viewClass(options)

  renderViews: () ->
    for selector, options of @views
      options.el = @$(selector)
      view = @createView(options)
      @compost[selector] = view
      view.render()


module.exports =
  mixins:
    Composite: Composite
  # views:
