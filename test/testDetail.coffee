bv = require "../src/index.coffee"
forms = require "forms"
jQuery = require "jquery"
Backbone = require "backbone"
jsdom = require "node-jsdom"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"

chai.use spies
assert = chai.assert
expect = chai.expect


describe "DetailMixin", ->

  beforeEach ->
    global.document = jsdom.jsdom()
    global.window = global.document.parentWindow
    Backbone.$ = jQuery(jsdom.jsdom().parentWindow)

    class TestView extends bv.views.MixinView
      mixins: [bv.mixins.DetailMixin]
      template: _.template "
        <div>
          <input type='checkbox' id='check'>
          <input type='text' id='text'>
          <i id='i'></i>
          <div data-foo='1'></div>
        </div>
      "
      bindings:
        checkbox: ":checkbox"
        textbox: "input[type=text]"
        italic: "i#i"

    @view = new TestView
      el: Backbone.$("<div id='detail'>")
      model: new Backbone.Model
        checkbox: true
        textbox: "text is fun"
        italic: "italic"
        foo: "fun"

    Backbone.$("body").append(@view.render().el)

  it "accepts data-name for auto binding", ->
    assert.equal @view.$el.find("[data-foo]").html(), "fun"

  it "updates properties on render", ->
    assert.equal @view.$el.find("#check").prop("checked"), true
    assert.equal @view.$el.find("#text").val(), "text is fun"
    assert.equal @view.$el.find("#i").html(), "italic"

  it "updates properties on change", ->
    Backbone.$("#check").prop("checked", false).trigger "change"
    Backbone.$("#text").val("awesome").trigger "change"
    Backbone.$("#i").html("checked")

    assert.equal @view.model.get("checkbox"), false
    assert.equal @view.model.get("textbox"), "awesome"
    assert.equal @view.model.get("italic"), "italic"  # didn't change

  it "updates model on change", ->
    @view.model.set("checkbox", false)
    @view.model.set("textbox", "awesome")
    @view.model.set("italic", "cool")

    assert.equal Backbone.$("#check").prop("checked"), false
    assert.equal Backbone.$("#text").val(), "awesome"
    assert.equal Backbone.$("#i").html(), "cool"
