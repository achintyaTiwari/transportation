uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

ServiceTypeSchema = new Schema({

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
    required: true
  }

  code: {
    type: String
    required: true
  }

  seating_capacity: {
    type: Number
  }

  basic_fare: {
    type: Number
    default: 0.0
  }

  minimum_fare: {
    type: Number
    default: 0.0
  }

  stage_distance_in_kms: {
    type: Number
    default: 0
  }

  stage_duration_in_mins: {
    type: Number
    default: 0
  }

  stage_fares: [{
    type: Number
    default: 0.0
  }]

  luggage_fare: {
    type: String
    ref: 'Fare'
  }

  service_tax: {
    type: Number
    default: 0.0
  }

  toll_charge: {
    type: Number
    default: 0.0
  }

  cess: {
    type: Number
    default: 0.0
  }

  round_off: {
    type: Number
    default: 1
  }

  is_pass_allowed: {
    type: Boolean
    default: true
  }

  is_concession_allowed: {
    type: Boolean
    default: true
  }

  payment_methods: [{
    type: String
    ref: 'PaymentMethod'
  }]

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

ServiceTypeSchema.index({operator: true, code: true}, {unique: true})

ServiceTypeSchema.plugin(deepPopulator)

module.exports = ServiceTypeSchema