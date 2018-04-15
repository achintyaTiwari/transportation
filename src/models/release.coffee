uuid = require 'uuid'
Schema = require('mongoose').Schema

ReleaseSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  application: {
    type: Number
    required: true
  }

  version: {
    type: String
    require: true
  }

  path: {
    type: String
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
      # this url is valid only for an hour
      doc.path = modules.storage.getUrl(doc.path, 60 * 60)
      _.omit(doc, ['_id', '__v',])
  }
})

module.exports = ReleaseSchema