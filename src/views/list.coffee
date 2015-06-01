Backbone = require "backbone"
_ = require "underscore"


class ListMixin
  itemViewClass: null
  listSelector: null

  initialize: (options) ->
    @views = {}
    @listenTo @collection, "add", @added
    @listenTo @collection, 'reset', @addAll
    @listenTo @collection, "remove", @removed

    @listenTo @, "render:post", @addAll

  getItemView: (model) ->
    return new @itemViewClass
      model: model

  getListElement: () ->
    if @listSelector
      @listEl = @$el.find @listSelector
    else
      @listEl = @$el
    return @listEl

  added: (model) ->
    view = @getItemView model
    @views[model.cid] = view
    @getListElement().append view.render().el

  removed: (model) ->
    view = @views[model.cid]
    if view
      view.remove()
      delete @views[model.cid]

  addAll: () ->
    @listEl = @getListElement()
    @$el.empty()
    @views = {}
    for model in @collection.models
      @added model


module.exports =
  mixins:
    ListMixin: ListMixin
