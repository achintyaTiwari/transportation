Schema = require('mongoose').Schema

LocationSchema = new Schema({

  device: {
    type: String
    ref: 'Device'
    required: true
  }

  schedule: {
    type: String
    ref: 'Schedule'
  }

  geo: {
    'type': {
      type: String
      'default': 'Point'
    },
    coordinates: {
      type: [Number]
      required: true
    }
  }

  speed: {
    type: Number
  }

  accuracy: {
    type: Number
  }

  bearing: {
    type: Number
  }

  created_at: {
    type: Date
    default: Date.now
  }

  reported_at: {
    type: Date
    default: Date.now
  }

}, {
  toObject: {
    virtuals: true
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      _.omit(doc, ['_id', '__v', 'id'])
  }
})

LocationSchema.index({'device': 1, 'geo': '2dsphere'});

module.exports = LocationSchema