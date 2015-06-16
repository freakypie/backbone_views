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
    </ul>
  '



module.exports =
  views:
    MenuItem: MenuItem
    Dropdown: Dropdown
    NavDropdown: NavDropdown
