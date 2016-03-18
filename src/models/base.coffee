_ = require "underscore"
Backbone = require "backbone"


class BaseModel extends Backbone.Model
  trailingSlash: true
  apiRoot: ""
  params: {}
  urlRoot: ""

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
      })


module.exports =
  models:
    BaseModel: BaseModel
    BaseCollection: BaseCollection
