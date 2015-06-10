# Backbone views

Provides some basic views to help you get started using Backbone

All examples below are written in coffeescript.
(That's what this library is written in.)

## Views


### MixinView

Provides an easy interface to mixins. All class based views in this package
will use this as their base class.

```coffeescript
bv = require("backbone_views")

class MyView extends bv.views.MixinView
  mixins: [bv.mixins.SelectorMixin]
```

A mixin is just a class. The prototype will be mixed in the current class.
If a `mixin` method is provided by the mixin, the it will be called during
the view's `initialize` method.

This view also provides basic rendering. It will call the template property
of the view if it exists.


## Default Generic Views
The views below are just simple implementations that use the mixins listed
at the bottom of the doc. For complicated stuff, you probably should write
your own.


### ListView
Uses the `ListMixin` below and a `DetailView` to provide a functioning list.
This view only requires that you give it a collection and it will make
an auto managed list. You really should override the detail template at least.

### CreateView
A simple view that uses the `FormMixin` to create and add a model to a
collection. You must provide a collection for this view to work.

### DetailView
Uses the `DetailMixin` below

### UpdateView
A simple view that updates a model using the `FormMixin`

### DeleteView
A simple view that provides a confirm form before destroying a model


## Mixins


### NunjucksMixin

Gives function to render a nunjucks form.

```coffeescript
bv = require("backbone_views")


class MyView extends bv.views.MixinView
  mixins: [bv.mixins.NunjucksMixin]
  template: require("my_view.html")
```

You can provide a `getContext` function to extend the context


### SelectorMixin

Selects elements after rendering

```coffeescript
bv = require("backbone_views")


class MyView extends bv.views.MixinView
  ui:
    input: ".form input#foo"

  # here is how you can use it, it will be jQueryied
  myFunc: () -> alert @ui.input.val()
```

### FormMixin

Provides a `renderForm` method to render a form from the npm forms package.
(Dang, that sentence is not formed well :D )

```coffeescript
bv = require "backbone_views"
forms = require "forms"


class MyView extends bv.views.MixinView
  mixins: [bv.mixins.FormMixin]  
  form: forms.create(
    name: form.fields.string(required: true)
  )
```

### BootstrapFormMixin

A form mixin that provides a bootstrapping form render function `bootstrapField`
for those who use bootstrap3

### ListMixin

When this mixin is provided a collection it will register listeners to
auto populate the collection in the view.

If a `listSelector` isn't provided or selects nothing,
it will assume the list should be populated on the view's `el`.

If an `emptySelector` is provided, it will hide/show the selector's results
whenever the list is empty/exists

```coffeescript
bv = require("backbone_views")
Backbone = require("backbone")


class MyView extends bv.views.MixinView
  mixins: [bv.mixins.ListMixin]  
  listSelector: ".list"
  emptySelector: ".empty"
  collection: new Backbone.Collection([{foo: "boo"}])
  template: '...'
```

### DetailMixin

This provides an easy way to bind properties to a view.
Set the property name and a selector on the `bindings` property and then
this model and the dom will be kept in sync

By default it will autobind unbound attrs to "data-{{ name }}", but you
can set the `autoBind` property to change it to something else or turn
off this feature.

```coffeescript
bv = require("backbone_views")
Backbone = require("backbone")


class MyView extends bv.views.MixinView
  mixins: [bv.mixins.DetailView]  
  bindings:
    fruit: "div .apple"
  template: '...'
```
