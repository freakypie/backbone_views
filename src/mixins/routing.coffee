_ = require "underscore"


class Routing
  ###
    events:
    - routing:opening -- sent to Backbone before a view is created
    - routing:closing -- sent to old view, before it is closed
  ###

  # will prefix all routes
  prefix: null

  # the current view
  # this will change if the router matches a URL
  view: null

  # a selector to determine which part of this view should be updated
  # when the router picks up a URL change
  routingSelector: ".main"

  # how long switching a view should take
  transitionDuration: 300

  routes: {}

  initialize: (options={}) ->
    @prefix = options.prefix? or ""

    @_router = new Backbone.Router()

    for url, opts of @routes
      if _.isFunction opts
        callback = opts
      else
        opts.router = @
        opts.prefix = @prefix + url
        opts.namedParams = opts.prefix.match(/:([a-z\-\_]+)/gi)
        callback = @update.bind(@, opts)
      @_router.route(@prefix + url, url, callback)
      # @routes[options.router] opts

  update: (options={}) ->
    reverse = options.reverse
    old = @view

    if old
      # notify the old view that it is being transitioned out
      old.trigger "routing:closing",
        router: @
        time: @transitionDuration
        reverse: options.reverse

      # remove after the transition is fully complete
      # we extend the time a little so the GPU can catch up before removal
      _.delay (-> old.remove()), @transitionDuration + 100

    # notify the world, a new view is coming in
    Backbone.trigger "routing:opening",
      router: @
      time: @transitionDuration
      reverse: options.reverse
      previousView: old
      options: options

    # add in the view
    args = (a for a in arguments)
    options.args = args[1..args.length]
    options.kwargs = _.object \
      ([options.namedParams[i]?.substring(1), a] for i, a of options.args)
    console.log options.kwargs
    @view = new options.viewClass(options)
    $(@routingSelector).append(@view.render().el)


module.exports =
  mixins:
    Routing: Routing
