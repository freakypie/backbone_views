_ = require "underscore"
Backbone = require "backbone"


class BaseModel extends Backbone.Model
  trailingSlash: true
  apiRoot: ""
  params: {}
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
    retval = @addTrailingSlash parts.join "/"

    if Object.keys(@params).length > 0
      retval += "?"
      retval += ("#{name}=#{value}" for name, value of @params).join("&")

    return retval

  addTrailingSlash: (url) ->
    if url[url.length - 1] != "/" and @trailingSlash
      url += "/"
    return url

  toString: () ->
    return @constructor.name

  @setApiRoot: (url) ->
    @::apiRoot = url

  @collection: ->
    return BaseCollection.extends model: @


class BaseCollection extends Backbone.Collection

  url: () ->
    return @model.prototype.url()

  set: (data=null) ->
    # attempt to detect pagination
    if _.isObject(data) \
    and "results" of data and "previous" of data and "next" of data
      console.log "pagination"
      @count = data.count
      @prev = data.previous
      @next = data.next
      super(data.results)
    else
      console.log "no pagination"
      super(data)


module.exports =
  models:
    BaseModel: BaseModel
    BaseCollection: BaseCollection
