Backbone = require "backbone"
_ = require "underscore"


class ListMixin
  itemViewClass: null
  listSelector: null
  emptySelector: ".empty"
  existsSelector: ".exists"
  loadingSelector: ".loading"
  errorSelector: ".error"
  emptyToggleClass: "hide"
  filters: null
  filterFunc: (model, filters) ->
    if filters
      for name, value of filters
        if _.isFunction(value)
          if not value(model.get(name))
            return false
        else if model.get(name) != value
          return false
    return true

  initialize: (options) ->
    if not @collection and not options.collection
      @collection = this.getCollection(options)
    @views = {}

    if @collection.params
      @collection.params.page = options.page or 1

    @listenTo @collection, "add", (m) =>
      @added(m)
    @listenTo @collection, 'reset', @addAll
    @listenTo @collection, "sort", ->
      # @empty()
      # @addAll()
      @sort()
    @listenTo @collection, "remove", @removed
    @listenTo @collection, "request", @showLoading.bind(@, true)
    @listenTo @collection, "error", @showError
    @listenTo @collection, "sync", @showLoading.bind(@, false)

    @listenTo @, "render:post", =>
      @addAll()

    @listenTo @, "close", (e) =>
      for id, view of @views
        view.trigger("close", e)

  getCollection: () ->
    return undefined

  setFilters: (filters) ->
    @filters = filters
    @updateFilters()

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

  sort: () ->
    included = []
    index = 0
    for model in @collection.models
      if @filterFunc model, @filters
        model.index = index
        included.push(model)
        index += 1

    for model in included
      view = @views[model.cid]
      current = view.$el.index()
      if model.index != current
        el = @getListElement().children().eq(model.index)
        el.before(view.$el.detach())

  empty: () ->
    @getListElement().empty()

  added: (model, container) ->
    if @filterFunc model, @filters
      skipShowEmpty = container == undefined
      if not container
        container = @getListElement().get(0)
      view = @getItemView model
      @views[model.cid] = view
      index = @collection.indexOf model
      rendered = view.render().el

      if not container.childNodes
        container.appendChild(rendered)
      else
        el = container.childNodes[index]
        if el
          container.insertBefore(rendered, el)
        else
          container.appendChild(rendered)

      if not skipShowEmpty
        @showEmpty()
      return view
    return null

  removed: (model) ->
    view = @views[model.cid]
    if view
      view.remove()
      delete @views[model.cid]
      @showLoading()
    return view

  addAll: () ->
    @listEl = @getListElement()
    @listEl.empty()
    @views = {}
    if @collection.length > 0
      container = document.createDocumentFragment()
      for model in @collection.models
        @added model, container
      if container
        @getListElement().append(container)

    @showEmpty()

  showError: () ->
    @showLoading(false)
    @$el.find(@errorSelector).removeClass @emptyToggleClass

  showLoading: (value) ->
    if value != undefined
      @loading = value
    if not @loading
      @$el.find(@loadingSelector).addClass @emptyToggleClass
      @showEmpty()
    else
      @$el.find(@loadingSelector).removeClass @emptyToggleClass
      @$el.find(@errorSelector).addClass @emptyToggleClass
      @$el.find(@emptySelector).addClass @emptyToggleClass

  showEmpty: () ->
    if not @loading
      count = null
      if @emptySelector or @existsSelector
        count = @count()

      if @emptySelector
        if count == 0
          @$(@emptySelector).removeClass @emptyToggleClass
        else
          @$(@emptySelector).addClass @emptyToggleClass

      if @existsSelector
        if count > 0
          @$el.find(@existsSelector).removeClass @emptyToggleClass
        else
          @$el.find(@existsSelector).addClass @emptyToggleClass

  remove: () ->
    for cid, view of @views
      view.remove()
      delete @views[cid]

  updateFilters: () ->
    count = 0
    for model in this.collection.models
      if @filterFunc model, @filters
        # if not added, add it
        if not @views[model.cid]
          this.added(model)
        count += 1
      else
        # if added, remove it
        view = @views[model.cid]
        if view
          view.remove()
          delete @views[model.cid]
    @showEmpty()
    return count

  count: () ->
    count = 0
    for model in this.collection.models
      if @filterFunc model, @filters
        count += 1
    return count

module.exports =
  mixins:
    ListMixin: ListMixin
