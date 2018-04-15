uuid = require 'uuid'
Schema = require('mongoose').Schema

JourneySchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  commuter: {
    type: String
    required: true
    ref: 'User'
  }

  order: {
    type: String
    required: true
    ref: 'Order'
  }

  trip: {
    type: String
    required: true
    ref: 'Trip'
  }

  token: {
    type: String
    required: true
  }

  start: {
    stage: { type: Number }
    location: { type: Schema.Types.Mixed }
    datetime: {
      type: Date
      default: Date.now
    }
  }

  end: {
    stage: { type: Number }
    location: { type: Schema.Types.Mixed }
    datetime: {
      type: Date
    }
  }

  status: {
    type: Number
    default: CONST.JOURNEY_STATUS.STARTED
  }

}, {
  versionKey: false
  timestamps: {
    createdAt: 'created_at'
    updatedAt: 'updated_at'
  }
  toObject: {
    virtuals: true
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      doc.status = _.findKey(CONST.JOURNEY_STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v'])
  }
})

module.exports = JourneySchema