uuid = require 'uuid'
Schema = require('mongoose').Schema

DeviceSchema = new Schema({

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

  application: {
    type: String
    required: true
  }

  depot: {
    type: String
    ref: 'Depot'
  }

  mac: {
    type: String
  }

  uuid: {
    type: String
    required: true
  }

  imei: {
    type: String
    required: true
  }

  token: {
    type: String
  }

  meta_data: {
    type: Schema.Types.Mixed
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
    transform: (instance, doc)->
      doc.id = doc._id
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v'])
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v'])
  }
})

DeviceSchema.index({uuid: true, imei: true}, {unique: true})

module.exports = DeviceSchema 