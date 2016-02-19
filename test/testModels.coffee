bv = require "../src/index.coffee"
jQuery = require "jquery"
Backbone = require "backbone"
jsdom = require "jsdom"
_ = require "underscore"
chai = require "chai"
spies = require "chai-spies"
nunjucks = require "nunjucks"

require "./testBase"

chai.use spies
assert = chai.assert
expect = chai.expect


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

    class TestCollection extends bv.models.BaseCollection
      urlRoot: "slugs"
      model: TestModel

    @collection = new TestCollection

  it "should have a correct assumption", ->
    @collection.add({foo: 1, bar: 1})
    @collection.add({foo: 2, bar: 1})
    assert.equal(@collection.where({bar: 1}).length, 2)

    # can't put functions in here
    #assert.equal(@collection.where({foo: (v) -> v == 2}).length, 1)

  it "should use the basemodel's urlroot", ->
    assert.equal(@collection.url(), "http://boo.com/slugs/?")

  it "should get all pages of models", (done) ->
    id_number = 1
    Backbone.sync = (method, model, options) ->
      options.success?({
        count: 6,
        page_size: 2,
        results: [
            {id: id_number + 1, name: "candy"},
            {id: id_number, name: "candy"}
        ],
        previous: null,
        next: null,
      }, {})

      id_number += 2

    @collection.fetchAllPages().then =>
      assert.equal(@collection.length, 6)
      done()
    .catch ->
      assert.fail()
      done()
