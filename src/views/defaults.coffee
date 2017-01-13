index = require "../mixins/index"
list = require "../mixins/list"
detail = require "../mixins/detail"
# form = require "../mixins/forms"
_ = require "underscore"


class DetailView extends index.views.MixinView
  base_mixins: [
    detail.mixins.SingleObjectMixin,
    detail.mixins.DetailMixin
  ]
  template: _.template "<%= model.toString() %>"


class ListView extends index.views.MixinView
  base_mixins: [list.mixins.ListMixin]
  itemViewClass: DetailView
  listSelector: ".list"
  listPaginatorSelector: ".pagination"
  template: _.template "<div class='list'></div>"
  fetch: false
  params: null
  pagination: null

  initialize: (options={}) ->
    super(options)
    if @params
      for name, value of @params
        @collection.params[name] = value

    if @fetch or options.fetch
      @collection.fetch()

    @listenTo @collection, "sync", ->
      if @collection.meta and @pagination and not @paginationViews
        @paginationViews = []
        for el in @$(@listPaginatorSelector).get()
          @paginationViews.push new @pagination(
            collection: @collection
            el: el
          ).render()
      else if @paginationViews
        for view in @paginationViews
          view.render()

class CreateView extends index.views.MixinView
  # base_mixins: [form.mixins.AutoFormMixin, form.mixins.FormMixin]
  template: _.template "<form><%= form %></form>"

  initialize: (options={}) ->
    super(options)

    if not @model
      if @collection
        @model = new @collection.model
      else
        console.error "You must provide a either a model or " + \
          "collection use CreateView"

  getData: () ->
    return @model.attributes

  formValid: (form) ->
    valid = @model.save(
      form.data,
      success: @success.bind(@, @model)
      error: (model, retval) =>
        console.log "failed to save", form, retval.responseJSON
        @formInvalid(form, retval.responseJSON)
    )
    if valid is false
      @formInvalid(form)

  success: (model) ->
    if @collection
      @collection.add model


class UpdateView extends index.views.MixinView
  base_mixins: [
    detail.mixins.SingleObjectMixin,
    # form.mixins.AutoFormMixin,
    # form.mixins.FormMixin
  ]
  template: _.template "<form><%= form %></form>"

  getData: () ->
    return @model.attributes

  formValid: (form) ->
    valid = @model.save(
      form.data,
      success: @success.bind(@)
      error: (retval) =>
        console.log "failed to save"
        @formInvalid(form, retval)
    )
    if valid is false
      @formInvalid(form)

  success: (model) ->


class DeleteView extends index.views.MixinView
  base_mixins: [detail.mixins.DetailMixin]
  template: _.template "<div>You need to override this template</div>"


module.exports =
  views:
    ListView: ListView
    DetailView: DetailView
    CreateView: CreateView
    UpdateView: UpdateView
    DeleteView: DeleteView
