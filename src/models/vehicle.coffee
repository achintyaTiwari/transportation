uuid = require 'uuid'
rand = require 'randomstring'
mongoose = require 'mongoose'
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

VehicleSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  operator: {
    type: String
    ref: 'Operator'
  }

  depot: {
    type: String
    ref: 'Depot'
  }

  reg_number: {
    type: String
    unique: true
    required: true
  }

  capacity: {
    type: Number
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

VehicleSchema.plugin(deepPopulator)

module.exports = VehicleSchema
