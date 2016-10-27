_ = require "underscore"

class Composite
  views: {}

  initialize: (options) ->
    this.compost = {}
    @listenTo @, "render:post", @renderViews

  createView: (viewClass, options) ->
    # TODO: send a composite key?
    return new viewClass(options)

  renderViews: () ->
    for selector, viewClass of @views
      options =
        selector: selector
        el: @$(selector).get(0)
      view = @createView(viewClass, options)
      if view
        @compost[selector] = view
        view.render()

  remove: () ->
    for selector, view of @compost
      view.remove()

module.exports =
  mixins:
    Composite: Composite
  # views:
