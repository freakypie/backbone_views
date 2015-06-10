
jsdom = require "node-jsdom"
jQuery = require "jquery"
Backbone = require "backbone"
chai = require "chai"
spies = require "chai-spies"
chai.use spies


beforeEach ->
  global.document = jsdom.jsdom()
  global.window = global.document.parentWindow
  Backbone.$ = jQuery(global.window)

  last_id = 0

  Backbone.sync = (method, model, options) ->
    # console.log("saving", method, model.cid)
    if method == "create"
      last_id += 1
      model.set("id", last_id)
    options.success?(model, {}, {})
