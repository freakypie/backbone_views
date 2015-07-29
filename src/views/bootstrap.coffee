index = require "./defaults"
_ = require "underscore"


class MenuItem extends index.views.DetailView
  el: '<li role="presentation">'
  template: _.template '
    <a role="menuitem" tabindex="-1" href="<%= link %>">
      <%= label %>
    </a>'


class Dropdown extends index.views.ListView
  itemViewClass: MenuItem
  listSelector: ".dropdown-menu"
  el: "<div class='dropdown'>"
  template: _.template '
    <button class="btn btn-default dropdown-toggle"
            type="button"
            id="<%= view_id %>"
            data-toggle="dropdown"
            aria-expanded="true">
      <%= view_label %>
      <span class="caret"></span>
    </button>
    <ul class="dropdown-menu" role="menu" aria-labelledby="<%= view_id %>">
    </ul>
  '

  initialize: (options={}) ->
    super(options)
    if options.label
      @label = options.label

  getContext: (context) ->
    context.view_id = @cid
    context.view_label = @label
    return super(context)


class NavDropdown extends Dropdown
  el: "<li class='dropdown'>"
  template: _.template '
    <a class="dropdown-toggle"
            type="button"
            id="<%= view_id %>"
            data-toggle="dropdown"
            aria-expanded="true">
      <%= view_label %>
      <span class="caret"></span>
    </a>
    <ul class="dropdown-menu" role="menu" aria-labelledby="<%= view_id %>">
    </ul>'


class Modal extends index.views.DetailView
  el: '<div class="modal fade">'
  template: _.template '
    <div class="modal-dialog <%= classes %>">
      <div class="modal-content">
        <div class="modal-header">
          <button type="button" class="close"
                  data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
          <h4 class="modal-title"><%= title %></h4>
        </div>
        <div class="modal-body">
          <%= body %>
        </div>
        <%= buttons %>
      </div>
    </div>'

  title: "Modal"
  body: ""
  # buttons:
  #   close: "default"
  classes: "modal-sm"
  events:
    "click .modal-footer button": "handleButton"
    'click .close': 'handleCancel'

  initialize: (options={}) ->
    _.extend @, options

    @listenTo @, "render:post", =>
      @$el.on "hidden.bs.modal", =>
        @remove()
      @$el.modal()

  getContext: (context) ->
    super(context)
    context.title = @title
    context.classes = @classes
    if _.isFunction @buttons
      buttons = @buttons(context)
    else
      buttons = ""
      for name, button of @buttons
        buttons += "
          <button type=\"button\"
                  class=\"btn btn-#{button}\"
                  data-name=\"#{name}\"
                  data-dismiss=\"modal\">
            #{name}
          </button>"
    if buttons
      buttons = "<div class=\"modal-footer\">#{buttons}</div>"
    context.buttons = buttons
    if _.isFunction @body
      body = @body(context)
    else
      body = @body
    context.body = body
    return context

  handleButton: (e) ->
    if @close
      @close(
        button: Backbone.$(e.target).data("name")
        modal: @
      )

  handleCancel: (e) ->
    null

  show: () ->
    @$el.modal("show")

  hide: () ->
    @$el.modal("hide")

  remove: () ->
    super()

  @create: (options) ->
    modal = new Modal(options)
    Backbone.$("body").append(modal.render().el)
    modal.show()
    return modal

  @error: (options) ->
    if options.title
      options.title = "<i class='fa fa-exclamation-triangle'></i> " + \
        options.title
    @create _.defaults options,
      title: "<i class='fa fa-exclamation-triangle'></i> Error"
      classes: "modal-sm text-danger"

  @info: (options) ->
    if options.title
      options.title = "<i class='fa fa-exclamation-triangle'></i> " + \
        options.title
    @create _.defaults options,
      title: "<i class='fa fa-exclamation-triangle'></i> Error"
      classes: "modal-sm text-info"


module.exports =
  views:
    MenuItem: MenuItem
    Dropdown: Dropdown
    NavDropdown: NavDropdown
    Modal: Modal
