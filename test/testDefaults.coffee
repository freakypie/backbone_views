bv = require "../src/index.coffee"
jQuery = require "jquery"
Backbone = require "backbone"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"
nunjucks = require "nunjucks"

require "./testBase"


chai.use spies
assert = chai.assert
expect = chai.expect


bv.models.BaseModel.setApiRoot "http://example.com"


class TestModel extends bv.models.BaseModel
  urlRoot: "slugs"
  toString: -> @get "text"
  defaults:
    foo: "----"
    bar: false
    baz: 0.9


class TestCollection extends bv.models.BaseCollection
  urlRoot: "slugs"
  model: TestModel


describe "ListView", ->

  it "should be rendered nicely with defaults", ->
    @view = new bv.views.ListView({collection: new TestCollection()})
    @view.collection.add {text: "fun"}

    Backbone.$("#content").empty().append(@view.render().el)

    assert.equal(
      Backbone.$("#content").html(),
      '<div><div class="list"><div>fun</div></div></div>'
    )

  it "shouldn't crash if model has not collection attr", ->
    @view = new bv.views.ListView({collection: new TestCollection()})
    model = @view.collection.add {text: "fun"}

    # we had reports on our error tracker that this was happening
    # don't know how it became null though
    model.collection = null
    @view.addAll()


describe "DetailView", ->

  beforeEach ->

    class TestView extends bv.views.DetailView
      model: new TestModel {text: "fun"}

    @view = new TestView()

    Backbone.$("#content").empty().append(@view.render().el)

  it "should be rendered nicely with defaults", ->
    assert.equal(
      Backbone.$("#content").html(),
      '<div>fun</div>'
    )

describe "CreateView", ->

  beforeEach ->

    class TestView extends bv.views.CreateView
      collection: new TestCollection

    @view = new TestView()

    Backbone.$("body").append(@view.render().el)

  it "should have a sane default", ->
    html = Backbone.$("body").html()
    assert.match(html, /<form/)
    assert.match(html, /<input/)
    assert.match(html, /<label/)

  it "when created, should add to the collection", (done) ->
    assert.equal @view.collection.length, 0
    @view.handleFormSubmit
      target: @view.$("form").get(0)
      preventDefault: _.noop
    _.defer =>
      assert.equal @view.collection.length, 1
      done()

  xit "should validate the form before creating", ->


describe "UpdateView", ->

  beforeEach ->

    class TestView extends bv.views.UpdateView
      model: new TestModel

    @view = new TestView()

    Backbone.$("body").append(@view.render().el)

  xit "should update the underlying model", (done) ->
    ### the dom doesn't seem to update ###
    assert.equal @view.$el.find("#id_foo").length, 1
    @view.$el.find("#id_foo").val("chew")
    _.defer =>
      assert.equal @view.$el.find("#id_bar").prop("checked"), true
      @view.handleFormSubmit
        target: @view.$("form").get(0)
        preventDefault: _.noop
      assert.equal @view.model.get("bar", true)
      done()


describe "DeleteView", ->

  beforeEach ->

    class TestView extends bv.views.DeleteView
      model: new TestModel

    @view = new TestView()

    Backbone.$("body").append(@view.render().el)

  xit "should be delete the model", ->
