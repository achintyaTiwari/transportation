console.log 'Teesri Line'

express = require 'express'
bodyParser = require 'body-parser'
endpoints = require './endpoints'

app = express()

app.use modules.middlewares.response.helpers
app.use bodyParser.json()
app.use bodyParser.urlencoded({ extended: true })
app.use modules.middlewares.cors
app.use modules.middlewares.logger.request
app.use '/v1', endpoints
if process.env.NODE_ENV isnt 'production'
  app.use '/v1/docs', modules.auth.basic, express.static('docs')
app.use modules.middlewares.response.errorHandler

app.init = ->
  db.connect().then(->
    console.log 'Connected to database...'
    app.listen(config.port, ->
      console.log "Application started and listening on port #{ config.port }"
    )
  ).catch((err=Error())->
    console.error err
    process.exit()
  ).done()

module.exports = app