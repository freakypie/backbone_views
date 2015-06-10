bv = require "../src/index.coffee"
forms = require "forms"
jQuery = require "jquery"
Backbone = require "backbone"
jsdom = require "node-jsdom"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"
nunjucks = require "nunjucks"


chai.use spies
assert = chai.assert
expect = chai.expect


bv.models.BaseModel.setApiRoot "http://example.com"


class TestModel extends bv.models.BaseModel
  urlRoot: "slugs"
  toString: -> @get "text"


class TestCollection extends bv.models.BaseCollection
  urlRoot: "slugs"
  model: TestModel


beforeEach ->
  global.document = jsdom.jsdom()
  global.window = global.document.parentWindow
  Backbone.$ = jQuery(global.window)


describe "ListView", ->

  beforeEach ->

    class TestView extends bv.views.ListView
      collection: new TestCollection

    @view = new TestView()
    @view.collection.add {text: "fun"}

    Backbone.$("body").append(@view.render().el)

  it "should be rendered nicely with defaults", ->
    assert.equal(
      Backbone.$("body").html(),
      '<ul class="list"><li>fun</li></ul>'
    )


describe "DetailView", ->

  beforeEach ->

    class TestView extends bv.views.DetailView
      model: new TestModel {text: "fun"}

    @view = new TestView()

    Backbone.$("body").append(@view.render().el)

  it "should be rendered nicely with defaults", ->
    assert.equal(
      Backbone.$("body").html(),
      '<div>You need to override this template</div>'
    )

describe "CreateView", ->

  beforeEach ->

    class TestView extends bv.views.CreateView
      collection: new TestCollection

    @view = new TestView()
    @view.collection.add {text: "fun"}

    Backbone.$("body").append(@view.render().el)

  xit "when created, should add to the collection", ->
  xit "should validate the form before creating", ->


describe "UpdateView", ->

  beforeEach ->

    class TestView extends bv.views.UpdateView
      collection: new TestCollection

    @view = new TestView()
    @view.collection.add {text: "fun"}

    Backbone.$("body").append(@view.render().el)

  xit "should update the underlying model", ->


describe "DeleteView", ->

  beforeEach ->

    class TestView extends bv.views.DeleteView
      collection: new TestCollection

    @view = new TestView()
    @view.collection.add {text: "fun"}

    Backbone.$("body").append(@view.render().el)

  xit "should be delete the model", ->
