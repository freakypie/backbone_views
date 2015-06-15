index = require "../mixins/index"
list = require "../mixins/list"
detail = require "../mixins/detail"
form = require "../mixins/forms"
forms = require "forms"
_ = require "underscore"


class DetailView extends index.views.MixinView
  base_mixins: [
    detail.mixins.SingleObjectMixin,
    detail.mixins.DetailMixin
  ]
  template: _.template "<div><%= model.toString() %></div>"


class ListView extends index.views.MixinView
  base_mixins: [list.mixins.ListMixin]
  itemViewClass: DetailView
  listSelector: ".list"
  template: _.template "<div class='list'></div>"


class CreateView extends index.views.MixinView
  base_mixins: [form.mixins.AutoFormMixin, form.mixins.FormMixin]
  template: _.template "<form><%= form %></form>"

  initialize: (options={}) ->
    super(options)

    if not @model
      if @collection
        @model = new @collection.model
      else
        console.error "You must provide a either a model or " + \
          "collection use CreateView"

  formValid: (form) ->
    console.log "saving form"
    valid = @model.save(
      form.data,
      success: @success.bind(@)
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
    form.mixins.AutoFormMixin,
    form.mixins.FormMixin
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
