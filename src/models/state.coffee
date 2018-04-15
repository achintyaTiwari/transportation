uuid = require 'uuid'
Schema = require('mongoose').Schema

StateSchema = new Schema({

  _id: {
    type: String
    unique: true
    uppercase: true
    maxlength: 2
  }

  name: {
    type: String
    required: true
  }

  regional_name: {
    type: String
  }

}, {
  versionKey: false
  toObject: {
    virtuals: true
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      _.omit(doc, ['_id'])
  }
})

module.exports = StateSchema