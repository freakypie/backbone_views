bv = require "../src/index.coffee"
forms = require "forms"
jQuery = require "jquery"
Backbone = require "backbone"
jsdom = require "node-jsdom"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"
nunjucks = require "nunjucks"

require "./testBase"

chai.use spies
assert = chai.assert
expect = chai.expect


describe "MixinView", ->

  beforeEach ->
    init = chai.spy()
    loaded = chai.spy()

    class ContextProvider
      getContext: (context) ->
        context.foo = true

    class TestMixin
      replaced: true

      initialize: () ->
        init()

        @listenTo @, "mixins:loaded", loaded

    class TestView extends bv.views.MixinView
      mixins: [ContextProvider, TestMixin]
      replaced: false

      initialize: () ->
        super()
        @listenTo @, "view:context", (context) ->
          context.listened = true

    @view = new TestView(el: Backbone.$("<div>"))
    Backbone.$("body").append(@view.render().el)

    @init = init
    @loaded = loaded

  it "adds mixins from `mixins` property", ->
    assert.equal(@view.listMixins().length, 2)

  it "calls `initialize` from every mixin", ->
    assert.equal(@init.__spy.calls.length, 1)

  it "won't replace class properties", ->
    assert.equal(@view.replaced, false)

  it "sends `mixins:loaded` signal", ->
    assert.equal(@loaded.__spy.calls.length, 1)

  it "calls all other context providers", ->
    assert.equal @view.getContext().foo, true

  it "sends a context signal for additional context", ->
    assert.equal @view.getContext().listened, true

  xit "can have global mixins installed"


describe "SelectorMixin", ->

  beforeEach ->
    class TestView extends bv.views.MixinView
      mixins: [bv.mixins.SelectorMixin]
      ui:
        cats: ".cats"
        dogs: "#dogs"

    @view = new TestView(el: Backbone.$("<div><i class='cats'></i></div>"))
    Backbone.$("body").append(@view.render().el)

  it "selects elments from `ui` property", ->
    @view.setupUI()
    assert.equal(@view.ui.cats.length, 1)
    assert.equal(@view.ui.dogs.length, 0)


describe "NunjucksMixin", ->

  beforeEach ->

    template1 = nunjucks.compile(
      '<div id="nunjucks"><i>nunjucks</i> Fun</div>'
    )

    class TestView extends bv.views.MixinView
      mixins: [bv.mixins.NunjucksMixin]
      template: template1
      templateSetRoot: true

    @view = new TestView(el: Backbone.$("<div id='no'></div>"))
    Backbone.$("body").append(@view.render().el)

  it "renders nunjucks template", ->
    assert.equal(@view.$el.find("i").length, 1)

  it "sets template as element", ->
    assert.equal(@view.$el.attr("id"), "nunjucks")
