uuid = require 'uuid'
Schema = require('mongoose').Schema

DepotSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  name: {
    type: String
    required: true
  }

  operator: {
    type: String
    ref: 'Operator'
    required: true
  }

  status: {
    type: Number
    default: CONST.STATUS.ACTIVE
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
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v', 'created_at', 'updated_at'])
  }
})

module.exports = DepotSchema