_ = require("underscore")

mods = [
  require('./mixins/index'),
  # require('./mixins/forms'),
  require('./mixins/list'),
  require('./mixins/detail'),
  require('./mixins/composite'),
  require('./mixins/routing'),
  require('./views/defaults'),
  require('./views/bootstrap'),
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

all = _.extend mixins, views, models

module.exports = _.extend all,
  mixins: mixins
  views: views
  models: models
