uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

FareSchema = new Schema({

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

  name: {
    type: String
  }

  code: {
    type: String
    required: true
  }

  slabs: [{
    name: {
      type: String
      required: true
    }
    value: {
      type: Number
      default: 0.0
      required: true
    }
  }]

  type: {
    type: String
    enum: ['LUGGAGE']
    uppercase: true
    required: true
  }

  status: {
    type: Number
    default: CONST.STATUS.ACTIVE
  }

}, {
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
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v', 'status', 'created_at', 'updated_at'])
  }
})

FareSchema.index({operator: true, code: true}, {unique: true})

FareSchema.plugin(deepPopulator)

module.exports = FareSchema