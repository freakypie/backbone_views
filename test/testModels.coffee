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


beforeEach ->
  global.document = jsdom.jsdom()
  global.window = global.document.parentWindow


describe "BaseModel", ->

  beforeEach ->
    bv.models.BaseModel.setApiRoot "http://boo.com"

    class TestModel extends bv.models.BaseModel
      apiRoot: "http://foo.com"
      urlRoot: "slugs"

    class TestModel2 extends bv.models.BaseModel
      urlRoot: "slugs"

    @model = new TestModel
    @model2 = new TestModel2

  it "should use the api", ->
    assert.equal(@model.url(), "http://foo.com/slugs/")

  it "should use the api when an instance", ->
    @model.id = 1
    assert.equal(@model.url(), "http://foo.com/slugs/1/")

  it "trailing slash is optional", ->
    @model.trailingSlash = false
    assert.equal(@model.url(), "http://foo.com/slugs")

  it "uses global api root when a local url is not set", ->
    assert.equal(@model2.url(), "http://boo.com/slugs/")

  it "should have a toString", ->
    assert.equal(@model.toString(), "TestModel")


describe "BaseCollection", ->

  beforeEach ->
    bv.models.BaseModel.setApiRoot "http://boo.com"

    class TestModel extends bv.models.BaseModel
      urlRoot: "slugs"

    class TestCollection extends bv.models.BaseModel
      urlRoot: "slugs"
      model: TestModel

    @collection = new TestCollection

  it "should use the basemodel's urlroot", ->
    assert.equal(@collection.url(), "http://boo.com/slugs/")
