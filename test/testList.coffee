bv = require "../src/index.coffee"
jQuery = require "jquery"
Backbone = require "backbone"
jsdom = require "jsdom"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"

require "./testBase"

chai.use spies
assert = chai.assert
expect = chai.expect

describe "ListMixin", ->

  beforeEach ->

    Backbone.sync = (method, model, options) ->
      if method == "create"
        last_id += 1
        model.set("id", last_id)
        options.success?(model, {}, {})

      if method == "read"
        options.success([])

    class TestItemView extends Backbone.View
      el: "<div class='item'>"

    @TestItemView = TestItemView

    class TestView extends bv.views.MixinView
      mixins: [bv.mixins.ListMixin]
      itemViewClass: TestItemView
    @view = new TestView
      el: "<div id='list'></div>"
      collection: new Backbone.Collection [{name: "one"}, {name: "two"}]

    @view2 = new TestView
      el: Backbone.$("<div id='list'>
        <div class='empty'></div>
        <div class='exists'></div>
        <div class='list'></div>
        </div>").get(0)
      collection: new Backbone.Collection []

    @view2.listSelector = ".list"

    Backbone.$("body").append(@view.el)
    Backbone.$("body").append(@view2.el)
    @view.trigger "render:post"
    @view2.trigger "render:post"

  it "adds an element when the collection gets a new element", ->
    @view.collection.add {name: "three"}
    assert.equal(@view.getListElement().children().length, 3)

  it "removes an element when the collection loses a new element", ->
    @view.collection.remove @view.collection.models[0]
    assert.equal(@view.$el.children().length, 1)

  it "addAll adds all models", ->
    @view.$el.empty()
    @view.addAll()
    assert(@view.$el.children().length, 2)

  it "destroys all subviews", ->
    chai.spy.on(@TestItemView.prototype, "remove")
    @view.remove()
    assert.equal(@view.$el.children().length, 0)
    assert.equal(@TestItemView::remove.__spy.calls.length, 2)

  it "shows `.empty` when collection is empty", () ->
    assert.equal(@view2.$(".empty").length, 1)
    assert.equal(@view2.$(".exists").length, 1)
    assert.equal(@view2.$(".empty").hasClass("hide"), false)
    assert.equal(@view2.$(".exists").hasClass("hide"), true)

  it "hides `.empty` when item is added", () ->
    assert.equal(@view2.$(".empty").hasClass("hide"), false)
    assert.equal(@view2.$(".exists").hasClass("hide"), true)
    @view2.collection.add {name: "three"}
    assert.equal(@view2.$(".empty").hasClass("hide"), true)
    assert.equal(@view2.$(".exists").hasClass("hide"), false)

  it "shows `.empty` when collection is reset", () ->
    @view2.collection.add {name: "three"}
    @view2.collection.reset([])
    assert.equal(@view2.$(".empty").hasClass("hide"), false)
    assert.equal(@view2.$(".exists").hasClass("hide"), true)

  it "shows `.empty` when collection is sync'd empty", () ->
    @view2.collection.add {name: "three"}
    @view2.collection.fetch()
    assert.equal(@view2.$(".empty").hasClass("hide"), false)
    assert.equal(@view2.$(".exists").hasClass("hide"), true)

  xit "filters newly added models", ->
  xit "filters current models", ->
