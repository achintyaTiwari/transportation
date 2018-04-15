mongoose = require 'mongoose'

mongoose.Promise = Q.Promise;

connect = (debug)->
  deferred = Q.defer()
  mongoose.set('debug', config.database.debug or false)
  if not _.isUndefined(debug) then mongoose.set('debug', debug)
  uri = config.database.uri or "mongodb://#{config.database.host}:#{config.database.port or 27017}/#{config.database.name}"
  mongoose.connect(uri, {
    user: config.database.username
    pass: config.database.password
  }, (err)->
    if err then deferred.reject(err)
  )
  mongoose.connection.on('connected', deferred.resolve)
  mongoose.connection.on('error', deferred.reject)
  deferred.promise

disconnect = ->
  mongoose.disconnect()

_.each({
  Assignment: 'assignment'
  Concession: 'concession'
  Depot: 'depot'
  Device: 'device'
  DeviceStatus: 'deviceStatus'
  Journey: 'journey'
  Location: 'location'
  Notification: 'notification'
  Operator: 'operator'
  Order: 'order'
  PaymentMethod: 'paymentMethod'
  Product: 'product'
  Route: 'route'
  Schedule: 'schedule'
  ServiceType: 'serviceType'
  Fare: 'fare'
  Session: 'session'
  State: 'state'
  Stop: 'stop'
  Trip: 'trip'
  User: 'user'
  Vehicle: 'vehicle'
  Sequence: 'sequence'
  Release: 'release'
}, (schemaPath, name)->
  mongoose.model(name, require __dirname + '/' + schemaPath)
)

module.exports = {
  connect: connect
  disconnect: disconnect
  models: mongoose.models
}