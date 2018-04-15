uuid = require 'uuid'
Schema = require('mongoose').Schema

NotificationSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  type: {
    type: Number
    required: true
  }

  from_account: {
    type: String
  }

  to: {
    type: String
    required: true
  }

  request: {
    type: Schema.Types.Mixed
  }

  reference: {
    type: String
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
  }
})

NotificationSchema.statics.log = (type, to, req, ref)->
  notification = @model('Notification')({
    type: type
    to: to
    request: _.pick(req, ['method', 'originalUrl', 'headers', 'body'])
    reference: ref
  })
  notification.save()

module.exports = NotificationSchema