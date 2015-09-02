Backbone = require "backbone"
_ = require "underscore"


class ListMixin
  itemViewClass: null
  listSelector: null
  emptySelector: ".empty"
  existsSelector: ".exists"
  loadingSelector: ".loading"
  emptyToggleClass: "hide"
  filter: null
  filterFunc: (model, filters) ->
    if filters
      for name, value of filters
        if model.get(name) != value
          return false
    return true

  initialize: (options) ->
    @views = {}

    if @collection.params
      @collection.params.page = options.page or 1

    @listenTo @collection, "add", @added
    @listenTo @collection, 'reset', @addAll
    @listenTo @collection, "remove", @removed
    @listenTo @collection, "request", @showLoading.bind(@, true)
    @listenTo @collection, "sync", @showLoading.bind(@, false)

    @listenTo @, "render:post", =>
      @showLoading()
      @addAll()

    @listenTo @, "close", (e) =>
      for id, view of @views
        view.trigger("close", e)

  setFilter: (filter) ->
    @filter = filter
    # TODO: remove models that no longer match
    # TODO: add models that are now matching

  getItemView: (model) ->
    return new @itemViewClass
      model: model
      parent: @

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
    if @filterFunc model, @filters
      view = @getItemView model
      @views[model.cid] = view
      @getListElement().append view.render().el
      @showEmpty()
      return view
    return null

  removed: (model) ->
    view = @views[model.cid]
    if view
      view.remove()
      delete @views[model.cid]
      @showEmpty()
    return view

  addAll: () ->
    @listEl = @getListElement()
    @listEl.empty()
    @views = {}
    if @collection.length > 0
      for model in @collection.models
        @added model

    @showEmpty()

  showLoading: (value) ->
    if value != undefined
      @loading = value
    if not @loading
      @$el.find(@loadingSelector).addClass @emptyToggleClass
      @showEmpty()
    else
      @$el.find(@loadingSelector).removeClass @emptyToggleClass
      @$el.find(@emptySelector).addClass @emptyToggleClass

  showEmpty: () ->
    if not @loading
      if @emptySelector
        if @collection.length == 0
          @$el.find(@emptySelector).removeClass @emptyToggleClass
        else
          @$el.find(@emptySelector).addClass @emptyToggleClass
      if @existsSelector
        if @collection.length > 0
          @$el.find(@existsSelector).removeClass @emptyToggleClass
        else
          @$el.find(@existsSelector).addClass @emptyToggleClass

  remove: () ->
    for cid, view of @views
      view.remove()
      delete @views[cid]



module.exports =
  mixins:
    ListMixin: ListMixin
