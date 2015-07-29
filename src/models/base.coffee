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
      retval += ("#{name}=#{value}" for name, value of params).join("&")

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
  params: {}
  
  url: (extra, params={}) ->
    if @params
      _.extend params, @params
    return @model.prototype.url(extra, params)

  parse: (data) ->
    data = super(data)

    # attempt to detect pagination
    if _.isObject(data) \
    and "results" of data and "previous" of data and "next" of data
      @count = data.count
      @prev = data.previous
      @next = data.next
      data = data.results

    return data


module.exports =
  models:
    BaseModel: BaseModel
    BaseCollection: BaseCollection
