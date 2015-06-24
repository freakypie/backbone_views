bv = require "../src/index.coffee"
forms = require "forms"
jQuery = require "jquery"
Backbone = require "backbone"
jsdom = require "node-jsdom"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"

require "./testBase"

chai.use spies
assert = chai.assert
expect = chai.expect

describe "ListMixin", ->

  beforeEach ->

    class TestItemView extends Backbone.View
      el: "<div class='item'>"

    @TestItemView = TestItemView

    class TestView extends bv.views.MixinView
      mixins: [bv.mixins.ListMixin]
      itemViewClass: TestItemView

    @view = new TestView
      el: Backbone.$("<div id='list'>").get(0)
      collection: new Backbone.Collection [{name: "one"}, {name: "two"}]

    Backbone.$("body").append(@view.el)
    @view.trigger "render:post"

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

  xit "filters newly added models", ->
  xit "filters current models", ->
