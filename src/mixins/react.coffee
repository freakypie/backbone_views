_ = require("underscore")

try
  React = require("react")


  class Reactor
    initialize: (options) ->
      if @model
        @listenTo @model, "change", =>
          @render()

      if @collection
        ["update", "remove", "reset", "sort"].forEach (event) =>
          @listenTo @collection, event, =>
            @render()

    component: ->
      # please put a React.Component here!

    getComponent: ->
      return @component

    renderer: (context) ->
      comp = @getComponent()
      if comp
        React.render(React.createElement(comp, context), @el)
      return this

catch
  Reactor = null


module.exports =
  mixins:
    Reactor: Reactor
