
require './globals'


app = require './app'


if require.main is module
  app.init()
else
  module.exports = {
    app: app
    boot: ->
      app.init()
    shutdown: ->
      app.close()
  }