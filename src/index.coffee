_ = require("underscore")

mods = [
  require('./mixins/index'),
  require('./mixins/forms'),
  require('./mixins/list'),
  require('./mixins/detail'),
  require('./views/defaults'),
  # require('./views/bootstrap'),
  require('./models/base'),
]

mixins = {}
views = {}
models = {}
for mod in mods
  _.extend(mixins, mod.mixins)
  _.extend(views, mod.views)
  if mod.models
    _.extend(models, mod.models)

module.exports =
  mixins: mixins
  views: views
  models: models
