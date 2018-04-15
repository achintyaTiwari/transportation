uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

ProductSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  name: {
    type: String
    required: true
  }

  desc: {
    type: String
  }

  price: {
    type: Number
    required: true
  }

  validity: {
    type: Number
    required: true
  }

  validity_type: {
    type: Number
    default: CONST.VALIDITY_TYPE.DAY
  }

  operator: {
    type: String
    ref: 'Operator'
    required: true
  }

  servicetypes: [{
    type: String,
    ref: 'ServiceType'
  }]

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
      doc.validity_type = _.findKey(CONST.VALIDITY_TYPE, (r)-> r is doc.validity_type)
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v', 'created_at', 'updated_at'])
  }
})

ProductSchema.plugin(deepPopulator)

module.exports = ProductSchema