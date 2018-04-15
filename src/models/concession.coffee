uuid = require 'uuid'
Schema = require('mongoose').Schema

ConcessionSchema = new Schema({

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

  names: {
    type: String
    required: true
  }

  code: {
    type: String
    required: true
  }

  reduction_value: {
    type: Number
    required: true
  }

  reduction_type: {
    type: String
    enum: ['PERCENTAGE', 'FIXED']
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

ConcessionSchema.index({operator: true, code: true}, {unique: true})

module.exports = ConcessionSchema