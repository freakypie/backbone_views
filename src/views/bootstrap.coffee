index = require "./defaults"
base = require "../mixins/index"
_ = require "underscore"


class MenuLink extends index.views.DetailView
  el: '<li role="presentation">'
  template: _.template '
    <a role="menuitem" tabindex="-1" href="<%= link %>">
      <%= label %>
    </a>'


class MenuItem extends index.views.DetailView
  el: '<li role="presentation" class="dropdown-header">'
  template: _.template '<%= label %>'


class Dropdown extends index.views.ListView
  itemViewClass: MenuLink
  itemNonLinkViewClass: MenuItem
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

  getItemView: (model) ->
    klass = @itemViewClass
    if not model.get("link")
      klass = @itemNonLinkViewClass
    return new klass
      model: model
      parent: @


class NavDropdown extends Dropdown
  el: "<li class='dropdown'>"
  template: _.template '
    <a href="#"
       class="dropdown-toggle"
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
    if not @model
      @model = new Backbone.Model()
    super(options)

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


class Pagination extends base.views.MixinView
  range: 3
  showPrevNext: false
  showFirstLast: true
  baseUrl: "/"
  template: _.template '
    <nav>
      <ul class="pagination">
        <li class="first">
          <a href="#" aria-label="Previous">
            <span aria-hidden="true"><i class="fa fa-step-backward"></i></span>
          </a>
        </li>
        <li class="prev">
          <a href="#" aria-label="Previous">
            <span aria-hidden="true"><i class="fa fa-caret-left"></i></span>
          </a>
        </li>
        <li class="next">
          <a href="#" aria-label="Next">
            <span aria-hidden="true"><i class="fa fa-caret-right"></i></span>
          </a>
        </li>
        <li class="last">
          <a href="#" aria-label="Next">
            <span aria-hidden="true">
              <span class="page-text"></span>
              <i class="fa fa-step-forward"></i>
            </span>
          </a>
        </li>
      </ul>
      <div>
        Displaying <%= meta.start %> - <%= meta.end %> of <%= meta.count %>
      </div>
    </nav>'

  events:
    "click .next a": "handleNext"
    "click .prev a": "handlePrev"
    "click .first a": "handleFirst"
    "click .last a": "handleLast"
    "click .page a": "handleClick"

  getContext: (context) ->
    page = @collection.params.page or 1
    context.meta = _.extend({}, @collection.meta.attributes)
    context.meta.page = page
    context.meta.start = @collection.params.page_size * (page - 1) + 1
    context.meta.end = Math.min(
      context.meta.count, @collection.params.page_size * (page))

    return context

  render: (context) ->
    super(context)

    # decipher which pages should be shown
    current = parseInt(@collection.params.page or 1)
    max = @collection.meta.get("pages")
    if max > 1
      moreNext = false
      morePrev = false
      if max > @range * 2 + 1
        start = current - @range
        end = current + @range
        moreNext = end < max
        morePrev = start > 1
        if start <= 0
          end -= start
          start = 1
        if end > max
          start -= (end - max)
          end = max
      else
        start = 1
        end = max

      # add in page links
      insert = @$(".next")
      if morePrev
        insert.before("<li class=\"page\"><span>...</span></li>")
      for page in [start..end]
        active = page == current and "active" or ""
        insert.before("<li class=\"page #{active}\">
          <a href=\"#\" data-page=\"#{page}\">#{page}</a>
        </li>")
      if moreNext
        insert.before("<li class=\"page\"><span>...</span></li>")

      # show/hide controls
      @$(".first,.last")[@showFirstLast and "removeClass" or "addClass"]("hide")
      @$(".next,.prev")[@showNextPrev and "removeClass" or "addClass"]("hide")
      # @$(".last .page-text").text(max)
      @$el.removeClass "hide"
    else
      @$el.addClass "hide"
    return @

  handleClick: (e) ->
    e.preventDefault()
    @goto($(e.target).data("page"))

  handleFirst: (e) ->
    e.preventDefault()
    @goto(1)

  handlePrev: (e) ->
    e.preventDefault()
    @goto(Math.max(@collection.params.page - 1, 1))

  handleNext: (e) ->
    e.preventDefault()
    @goto(Math.min(@collection.params.page + 1, @collection.meta.get("pages")))

  handleLast: (e) ->
    e.preventDefault()
    @goto(@collection.meta.get("pages"))

  goto: (page) ->
    if not @loading
      @loading = true
      @oldPage = @collection.params.page or 1
      @collection.params.page = page
      @$(".page [data-page=#{page}]").html(
        "<i class='fa fa-refresh fa-spin'></i>")
      @collection.fetch
        reset: true
        success: =>
          @render()
          @url(page)
          @loading = false
        error: =>
          @goto @oldPage

  url: (page) ->
    # customize this


module.exports =
  views:
    Pagination: Pagination
    MenuItem: MenuItem
    Dropdown: Dropdown
    NavDropdown: NavDropdown
    Modal: Modal
