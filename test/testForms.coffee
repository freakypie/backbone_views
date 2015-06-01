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


describe "FormMixin", ->
  global.document = jsdom.jsdom()
  global.window = global.document.parentWindow

  beforeEach ->
    Backbone.$ = jQuery(jsdom.jsdom().parentWindow)
    class TestFormView extends bv.views.MixinView
      mixins: [bv.mixins.FormMixin]
      form: forms.create
        field1: forms.fields.string
          required: true

      render: (context={}) ->
        form = @getForm()
        @$el.empty()
        @$el.append("<form>" + form.toHTML() + "</form>")
        return @el

      formValid: (form) ->
      formInvalid: (form) ->

    @view = new TestFormView(el: Backbone.$("<div id='form'>"))
    Backbone.$("body").append(@view.render().el)

    chai.spy.on @view, "formValid"
    chai.spy.on @view, "formInvalid"

  it "calls `formValid` when form is valid", ->

    @view.$("input").val("checked")
    @view.handleFormSubmit
      target: @view.$("form").get(0)

    expect(@view.formInvalid).not.to.have.been.called()
    expect(@view.formValid).to.have.been.called()

  it "calls `formInvalid` when form has errors", ->

    @view.handleFormSubmit
      target: @view.$("form").get(0)

    expect(@view.formValid).not.to.have.been.called()
    expect(@view.formInvalid).to.have.been.called()
