
jsdom = require "jsdom"
jQuery = require "jquery"
Backbone = require "backbone"
chai = require "chai"
spies = require "chai-spies"
chai.use spies


beforeEach "setup dom", (done) ->
  last_id = 0

  Backbone.sync = (method, model, options) ->
    # console.log("saving", method, model.cid)
    if method == "create"
      last_id += 1
      model.set("id", last_id)
      options.success?(model, {}, {})

  dom = "
  <html>
    <body>
      <div id='content'>
      </div>
    </body>
  </html>"
  jsdom.env dom, [jQuery], (err, window) ->
    global.document = window.document
    global.window = window
    Backbone.$ = jQuery(window)
    done()
