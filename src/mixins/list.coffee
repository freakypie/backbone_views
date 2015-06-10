Backbone = require "backbone"
_ = require "underscore"


class ListMixin
  itemViewClass: null
  listSelector: null
  emptySelector: ".empty"
  emptyToggleClass: "hide"

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
      selected = @$el.find @listSelector
      if selected.length > 0
        @listEl = selected
      else
        @listEl = @$el
    else
      @listEl = @$el
    return @listEl

  added: (model) ->
    view = @getItemView model
    @views[model.cid] = view
    @getListElement().append view.render().el
    @showEmpty()

  removed: (model) ->
    view = @views[model.cid]
    if view
      view.remove()
      delete @views[model.cid]
      @showEmpty()

  addAll: () ->
    @listEl = @getListElement()
    @listEl.empty()
    @views = {}
    if @collection.length > 0
      for model in @collection.models
        @added model

    @showEmpty()

  showEmpty: () ->
    if @emptySelector
      if @collection.length == 0
        @$el.find(@emptySelector).removeClass @emptyToggleClass
      else
        @$el.find(@emptySelector).addClass @emptyToggleClass


module.exports =
  mixins:
    ListMixin: ListMixin
