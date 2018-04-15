uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

StopSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  operator: {
    type: String
    ref: 'Operator'
    required: true
  }

  code: {
    type: String
    uppercase: true
    required: true
  }

  name: {
    type: String
    required: true
  }

  regional_name: {
    type: String
  }

  place_id: {
    type: String
    required: true
  }

  location: {
    'type': {
      type: String
      'default': 'Point'
    },
    coordinates: {
      type: [Number]
      required: true
    }
  }

  state: {
    type: String
    ref: 'State'
    required: true
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
      _.omit(doc, ['_id', '__v', 'created_at', 'updated_at'])
  }
})

StopSchema.index({ location : '2dsphere' })
StopSchema.index({ operator : true, place_id: true }, {unique: true})

StopSchema.plugin(deepPopulator)

module.exports = StopSchema