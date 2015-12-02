index = require "./index"
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
  routingSelector: null

  # how long switching a view should take
  transitionDuration: 300

  routes: {}

  initialize: (options={}) ->
    @router = options.router

    if not Backbone.History.started
      @prefix = options.prefix or ""
      if "*" in @prefix
        @prefix = @prefix.split("*")[0]

      @routers = {}
      @_router = new Backbone.Router()

      for url in Object.keys(@routes).reverse()
        view = @routes[url]
        callback = null

        # TODO: check if view is a backbone router

        if view.prototype instanceof Backbone.View
          prefix = @prefix + url

          # is Routing Mixin?
          if index.views.MixinView.listMixins(view).indexOf(Routing) > -1
            @routers[url] = new view
              router: @,
              prefix: prefix
          else
            # normal class based view
            opts = {router: @, viewClass: view, prefix: prefix}
            opts.namedParams = opts.prefix.match(/:([a-z\-\_]+)/gi)
            callback = @update.bind(@, opts)

        else if _.isFunction view
          callback = view.bind(this)

        else
          console.error "This view is not an view class or callback", view

        if callback
          @_router.route(@prefix + url, url, callback)

  remove: () ->
    console.log "detaching element"
    $(@el).detach()
    return false

  update: (options={}) ->
    reverse = false
    if options.reverse != undefined
      reverse = options.reverse
    if Backbone.app.reverse != undefined
      reverse = Backbone.app.reverse

    # attach the router if isn't attached
    if not document.body.contains @el
      if @router
        @router.update
          view: @
          reverse: reverse
      else
        new Exception(
          "Don't know how you want to attach this router to the dom.
          Usually it is rendered and attached by another view or the main app"
        )

    old = @view
    if old
      # notify the old view that it is being transitioned out
      Backbone.trigger "routing:closing",
        router: @
        view: old
        time: @transitionDuration
        reverse: reverse

      # remove after the transition is fully complete
      # we extend the time a little so the GPU can catch up before removal
      _.delay =>
        old.remove()
      , @transitionDuration + 100

    if options.viewClass
      # add in the view
      args = (a for a in arguments)
      options.args = args[1..args.length]
      if options.namedParams
        options.kwargs = _.object \
          ([options.namedParams[i]?.substring(1), a] for i, a of options.args)
      else
        options.kwargs = {}
      _.defaults options, {router: @}
      @getRouteOptions(options)
      view = new options.viewClass(options)
    else
      view = options.view

    if view
      view = view.render()
      if view and view.el
        @getRoutingElement().append(view.el)

        # notify the world, a new view is coming in
        Backbone.trigger "routing:opened",
          router: @
          time: @transitionDuration
          reverse: reverse
          previousView: @view
          options: options
          view: view

        # now safe to set view
        @view = view
    else
      console.warn("NO view given to router", options)
      @view = null

  getRouteOptions: (options) ->
    return options

  getRoutingElement: () ->
    if @routingSelector
      return $(@routingSelector)
    return @$el


module.exports =
  mixins:
    Routing: Routing
