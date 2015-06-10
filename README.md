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


## Mixins


### NunjucksMixin

Gives function to render a nunjucks form.

```coffeescript
bv = require("backbone_views")
Backbone = require("backbone")
underscore = require("underscore")


class MyView extends Backbone.View
  template: require("my_view.html")

  initialize: () ->
      _.extend @, bv.mixins.NunjucksMixin

  render: () ->
    @renderNunjucksTemplate()
    return this
```

You can provide a `getContext` function to extend the context


### ContextMixin

provides a "getContext" function that sends a "view:context" signal
All mixins can listen for this signal and update the context.


### SelectorMixin

Selects elements after rendering

```coffeescript
bv = require("backbone_views")
Backbone = require("backbone")
underscore = require("underscore")


class MyView extends Backbone.View

  ui:
    input: ".form input#foo"

  initialize: () ->
      _.extend @, bv.mixins.SelectorMixin

  render: () ->
    @selectUI()
    #ui.input is set to the element in the selector
    return this
```

### FormMixin

Provides a `renderForm` method to render a form from the npm forms package.
(Dang, that sentence is not formed well :D )

```coffeescript
bv = require("backbone_views")
Backbone = require("backbone")
underscore = require("underscore")


class MyView extends bv.views.MixinView
  mixins: [bv.mixins.FormMixin]  
  form: forms.create(
    name: form.fields.string(required: true)
  )

  render: (context={}) ->
    @renderForm(context)
    return this
```

### BootstrapFormMixin

A form mixin that provides a bootstrapping form render function `bootstrapField`


### ListMixin

When this mixin is provided a collection it will register listeners to
auto populate the collection in the view.

If a `listSelector` isn't provided, it will assume the list should be
populated on the view's `el`.

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
