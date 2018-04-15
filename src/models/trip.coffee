uuid = require 'uuid'
mongoose = require 'mongoose'
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

TripSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  waybill: {
    type: String
    ref: 'Assignment'
    required: true
  }

  schedule: {
    type: String
    ref: 'Schedule'
    required: true
  }

  start: {
    location: { type: Schema.Types.Mixed }
    datetime: {
      type: Date
      default: Date.now
    }
  }

  end: {
    location: { type: Schema.Types.Mixed }
    datetime: {
      type: Date
    }
  }

  hash: {
    type: String
    unique: true
    required: true
  }

  secret_key: {
    type: String
    required: true
    select: false
  }

  status: {
    type: Number
    default: CONST.TRIP_STATUS.STARTED
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
      doc.status = _.findKey(CONST.TRIP_STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v',])
  }
})

TripSchema.plugin(deepPopulator)

module.exports = TripSchema