_ = require("underscore")

mods = [
  require('./views/index'),
  require('./views/forms')
]

mixins = {}
views = {}
for mod in mods
  _.extend(mixins, mod.mixins)
  _.extend(views, mod.views)

module.exports =
  mixins: mixins
  views: views
