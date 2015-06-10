index = require "../mixins/index"
list = require "../mixins/list"
_ = require "underscore"



class MenuItem extends index.views.MixinView
  template: _.template '<li role="presentation">
    <a role="menuitem" tabindex="-1" href="<%= link %>">
      <%= label %>
    </a>
  </li>'


class Dropdown extends index.views.MixinView
  mixins: [list.mixins.ListMixin]
  itemViewClass: MenuItem
  listSelector: ".dropdown-menu"
  template: _.template '<div class="dropdown">
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
  </div>'

  initialize: (options={}) ->
    super(options)
    @label = options.label

  getContext: (context) ->
    context.view_id = @cid
    context.view_label = @label
    return super(context)


class ListView extends index.views.MixinView

module.exports =
  views:
    Dropdown: Dropdown
