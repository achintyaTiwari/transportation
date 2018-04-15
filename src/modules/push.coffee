admin = require 'firebase-admin'

admin.initializeApp({
  credential: admin.credential.cert(config.firebase_service_account.credential)
  databaseURL: config.firebase_service_account.databaseURL
})

module.exports = {
  toDevices: (tokens, data={}, notification={}, retry=1, options={})->
    payload = {
      data: data
      notification: notification
    }

    options = _.extend({
      priority: 'high'
      timeToLive: 60 * 60 * 24
    }, options)

    return admin.messaging().sendToDevice(tokens, payload, options)

  toTopic: (topic, data={}, notification={}, retry=1, options={})->
    payload = {
      data: data
      notification: notification
    }

    options = _.extend({
      priority: 'high'
      timeToLive: 60 * 60 * 24
    }, options)

    return admin.messaging().sendToTopic(topic, payload, options)
}
