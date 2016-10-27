_ = require "underscore"
Backbone = require "backbone"


class BaseModel extends Backbone.Model
  trailingSlash: true
  apiRoot: ""
  params: {}
  urlRoot: ""

  initialize: (options) ->
    super(options)

    # promise to indicate that the model is loaded
    this.loaded = new Promise (resolve, reject) =>
      if this.id
        resolve()
      else
        this.listenToOnce this, "sync", () ->
          resolve()

  url: (extra, params) ->
    parts = []
    if @apiRoot
      parts.push @apiRoot
    if @urlRoot
      parts.push @urlRoot
    if @id
      parts.push "" + @id
    if extra
      parts.push extra
    retval = @addTrailingSlash parts.join "/"

    if params or Object.keys(@params).length > 0
      _.extend params, @params
      retval += "?"
      bits = []
      for name, value of params
        if not (value is undefined)
          bits.push("#{name}=#{value}")
      retval += bits.join("&")

    return retval

  addTrailingSlash: (url) ->
    if url[url.length - 1] != "/" and @trailingSlash
      url += "/"
    return url

  toString: () ->
    return @constructor.name

  @setApiRoot: (url) ->
    @::apiRoot = url

  @collection: (extras) ->
    return new (BaseCollection.extend _.extend(model: @, extras))

  @all: () ->
    if not this._collection
      this._collection = this.collection()
      this._collection.fetch()
    return this._collection


class BaseCollection extends Backbone.Collection
  params: null
  meta: null
  pageSize: null

  initialize: (options={}) ->
    super(options)
    if not @params
      @params = {}
    if options.pageSize
      @params.page_size = options.pageSize

    # promise to indicate that the collection has synced
    this.synced = new Promise (resolve, reject) =>
      this.listenToOnce this, "sync", () ->
        resolve()

  url: (extra, params={}) ->
    if @params
      _.extend params, @params
    return @model.prototype.url(extra, params)

  parse: (data) ->
    data = super(data)

    # attempt to detect pagination
    if _.isObject(data) \
    and "results" of data and "previous" of data and "next" of data
      if not @meta
        @meta = new Backbone.Model()
      page_size = @params.page_size or data.results.length
      @meta.set
        count: data.count
        pageSize: page_size
        pages: data.pages or Math.ceil(data.count / page_size)
        prev: data.previous
        next: data.next
      data = data.results

    return data

  getOrCreate: (filters, defaults={}, fetch=true) ->
    instance = this.findWhere(filters)
    if not instance
      instance = new this.model(_.defaults(defaults, filters))
      this.add(instance)
      if fetch and instance.id
        instance.fetch()
    return instance

  ###
    Gets a model or returns a stub model

    When data becomes available later,
    the stub will be updated if a match is found
  ###
  getOrStub: (filters, defaults={}) ->
    instance = this.findWhere(filters)
    if not instance
      instance = new this.model(_.defaults(defaults, filters))

      # if we are finding with an id
      # we can add to the collection and it should auto update
      if instance.id
        this.add(instance)
      else
        # if we don't have an id, we manually update
        instance.listenTo this, "update", =>
          instance2 = this.findWhere(filters)
          if instance2
            instance.set(instance2.attributes)
    return instance

  getWhen: (filters, timeout=3000) ->
    return new Promise((resolve, reject) =>
      listener = () =>
        temp = this.findWhere(filters)
        if temp
          this.stopListening(this, "update", listener)
          this.stopListening(this, "reset", listener)
          resolve(temp)
        return temp

      if not listener()
        this.listenTo(this, "update", listener)
        this.listenTo(this, "reset", listener)

        if timeout
          _.delay =>
            this.stopListening(this, "update", listener)
            this.stopListening(this, "reset", listener)
            reject(null)
          , timeout
    )

  fetchAllPages: (page=1) ->
    """ Recursively fetch all pages starting at the given page """
    return new Promise (resolve, reject) =>
      @fetchPage(page)
        .then =>
          page += 1
          if @meta and page <= @meta.get("pages")
            @fetchAllPages(page).then ->
              resolve()
            .catch(reject)
          else
            resolve()
        .catch (ex) ->
          reject(ex)

  fetchPage: (page) ->
    return new Promise (resolve, reject) =>
      if not @params
        @params = {}
      @params.page = page
      @fetch({
        remove: false,
        success: (retval) ->
          resolve()
        error: (collection, xhr) ->
          reject(xhr)
      })


module.exports =
  models:
    BaseModel: BaseModel
    BaseCollection: BaseCollection
