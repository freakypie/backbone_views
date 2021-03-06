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
  listLimit: null
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

    # states: loading <=> listing
    #                 <=> error
    count = @count()
    @listMeta = new Backbone.Model({
      state: "listing",
      count: count,
    });

    # @listenTo @collection, "all", (event) =>
    #   console.log(" => #{event}")
    # @listenTo @collection, "add", (m) =>
    #   @added(m)
    @listenTo @collection, 'update', =>
      @listMeta.set({state: "listing"})
      @updateFilters()
    @listenTo @collection, 'reset', =>
      @listMeta.set({state: "listing"})
      @empty()
      @updateFilters()
    @listenTo @collection, "sort", ->
      # objects might be added after sort is called. not sure why
      # defering it makes the added objects available to sort
      _.defer( => @sort())
    @listenTo @collection, "request", =>
      @listMeta.set({state: "loading"})
      @showAlerts()
    @listenTo @collection, "error", =>
      @listMeta.set({state: "error"})
      @showAlerts()
    @listenTo @collection, "sync", =>
      @listMeta.set({state: "listing"})
      @showAlerts()

    # removed from the collection
    @listenTo @collection, "remove", @removed

    # # destroyed
    # @listenTo @collection, "destroy", @removed

    @listenTo @, "render:post", =>
      @prevState = @listMeta.get("state")
      @listMeta.set({state: "loading"})
      @addAll()
      @listMeta.set({state: @prevState})
      @showAlerts()

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

    @cachedCount = index

    for model in included
      view = @views[model.cid]
      if view
        current = Backbone.$(view.$el).index()
        if current == -1 or model.index != current
          el = @getListElement().children().eq(model.index)
          if el.length > 0
            el.before(Backbone.$(view.$el))
          else
            @getListElement().append(Backbone.$(view.$el))

  empty: () ->
    @getListElement().empty()
    @views = {}

  added: (model, container, sIndex) ->
    if @filterFunc model, @filters
      view = @_added(model, container, sIndex)
      @showAlerts()
      return view
    return null

  _added: (model, container, sIndex) ->
    if not container
      container = @getListElement().get(0)

    # we must find what position this view should be in
    # count will tell us which index it is supposed to be at
    if sIndex is undefined
      model.index = @cachedCount
    else
      model.index = sIndex
    index = model.index

    # if using a container, we'll have to modify the index just a bit
    # Might want to sort this later
    if container
      index = container.childNodes.length

    if this.listLimit is null or model.index < this.listLimit
      view = @getItemView model
      @views[model.cid] = view
      rendered = view.render().el

      if not container.childNodes
        container.appendChild(rendered)
      else
        el = container.childNodes[index]
        if el
          container.insertBefore(rendered, el)
        else
          container.appendChild(rendered)
      @cachedCount += 1
      return view

  removed: (model) ->
    view = @views[model.cid]
    if view
      view.remove()
      delete @views[model.cid]
      @cachedCount -= 1
    return view

  addAll: () ->
    @listEl = @getListElement()
    @listEl.empty()
    @views = {}
    if @collection.length > 0
      @addGroup(@collection.models)

  addGroup: (group) ->
    if group.length > 0
      container = document.createDocumentFragment()
      group.forEach (instance) =>
        this.added(instance, container)

      this.getListElement().append(container)

  remove: () ->
    for cid, view of @views
      view.remove()
      delete @views[cid]

  updateFilters: () ->
    count = 0
    for model in this.collection.models
      if @filterFunc model, @filters
        # should this view be added?
        if (this.listLimit is null or count < this.listLimit)
          if not @views[model.cid]
            this._added(model, null, count)
        else if @views[model.cid]
          this.removed(model)
        model.index = count
        count += 1
      else
        # if added, remove it
        @removed(model)

    @cachedCount = count
    @showAlerts()

    return count

  count: (countUntil) ->
    count = 0
    for model in this.collection.models
      if countUntil and model.id == countUntil.id
        break
      if @filterFunc model, @filters
        model.index = count
        count += 1
    if not countUntil
      @cachedCount = count
    return count

  showAlerts: () ->
    state = @listMeta.get("state", "listing")
    if state == "listing" and @cachedCount == 0
      state = "empty"

    states = {
      "loading": @loadingSelector,
      "error": @errorSelector,
      "empty": @emptySelector
    }
    activated = false
    for priority, selector of states
      # show the alert if it is the current state
      # unless a higher order alert was already activated
      if not activated and state == priority
        @showAlert(selector)
        activated = true
      else
        @hideAlert(selector)

    if @cachedCount > 0
      @showAlert(@existsSelector)
    else
      @hideAlert(@existsSelector)

  showAlert: (selector) ->
    status = @listMeta.get(selector)
    if not status or status is undefined
      # console.log("[alert on] #{selector}")
      @listMeta.set(selector, true)
      @$el.find(selector).removeClass @emptyToggleClass
    # else
    #   console.log("[alert already on] #{selector} #{status}")

  hideAlert: (selector) ->
    status = @listMeta.get(selector)
    if status or status is undefined
      # console.log("[alert off] #{selector}")
      @listMeta.set(selector, false)
      @$el.find(selector).addClass @emptyToggleClass
    # else
    #   console.log("[alert already off] #{selector} #{status}")

module.exports =
  mixins:
    ListMixin: ListMixin
