_ = require "underscore"
Backbone = require "backbone"


class BaseModel extends Backbone.Model
  trailingSlash: true
  apiRoot: ""
  urlRoot: ""

  url: (extra) ->
    parts = []
    if @apiRoot
      parts.push @apiRoot
    if @urlRoot
      parts.push @urlRoot
    if @id
      parts.push "" + @id
    if extra
      parts.push extra
    return @addTrailingSlash parts.join "/"

  addTrailingSlash: (url) ->
    if url[url.length - 1] != "/" and @trailingSlash
      url += "/"
    return url

  toString: () ->
    return @constructor.name

  @setApiRoot: (url) ->
    @::apiRoot = url


class BaseCollection extends Backbone.Collection

  url: () ->
    return @model.prototype.url()

  set: (data=null) ->
    # attempt to detect pagination
    if _.isObject(data) \
    and "results" of data and "prev" of data and "next" of data
      @count = data.count
      @prev = data.previous
      @next = data.next
      super(data.results)
    else
      super(data)


module.exports =
  models:
    BaseModel: BaseModel
    BaseCollection: BaseCollection
