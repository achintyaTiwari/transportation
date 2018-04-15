uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

OrderSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  seq: {
    type: String
  }

  users: [{
    type: String
    ref: 'User'
  }]

  schedule: {
    type: String
    ref: 'Schedule'
  }

  product: Schema.Types.Mixed

  amount: {
    type: Number
  }

  payment: {
    id: String
    method: {
      type: String
      ref: 'PaymentMethod'
    }
    meta_data: Schema.Types.Mixed
  }

  validity: {
    type: Schema.Types.Mixed
  }

  validity_type: {
    type: Number
  }

  type: {
    type: String
    enum: ['PASSENGER_TICKET', 'CONCESSION_TICKET', 'LUGGAGE_TICKET', 'PASS', 'ONLINE_BOOKING']
    uppercase: true
    required: true
  }

  channel: {
    id: {
      type: String
    }
  }

  status: {
    type: Number
    default: CONST.ORDER_STATUS.CREATED
  }

}, {
  versionKey: false
  timestamps: {
    createdAt: 'created_at'
    updatedAt: 'updated_at'
  }
  toObject: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      doc.status = _.findKey(CONST.ORDER_STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v'])
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      doc.status = _.findKey(CONST.ORDER_STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v'])
  }
})

OrderSchema.plugin(deepPopulator)

module.exports = OrderSchema