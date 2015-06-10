index = require "../mixins/index"
list = require "../mixins/list"
detail = require "../mixins/detail"
form = require "../mixins/forms"
_ = require "underscore"


class ListItemView extends index.views.MixinView
  base_mixins: [detail.mixins.DetailMixin]
  template: _.template "<li><%= model.toString() %></li>"


class ListView extends index.views.MixinView
  base_mixins: [list.mixins.ListMixin]
  itemViewClass: ListItemView
  listSelector: ".list"
  template: _.template "<ul class='list'></ul>"


class DetailView extends index.views.MixinView
  base_mixins: [detail.mixins.DetailMixin]
  template: _.template "<div>You need to override this template</div>"


class CreateView extends index.views.MixinView
  base_mixins: [detail.mixins.FormMixin]
  template: _.template "<div>You need to override this template</div>"


class UpdateView extends index.views.MixinView
  base_mixins: [detail.mixins.DetailMixin]
  template: _.template "<div>You need to override this template</div>"


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
    ListItemView: ListItemView
