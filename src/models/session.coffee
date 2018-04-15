Schema = require('mongoose').Schema

SessionSchema = new Schema({

  token: {
    type: String
    required: true
  }

  user: {
    type: String
    ref: 'User'
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
  toObject: { virtuals: true }
  toJSON: { virtuals: true }
})

module.exports = SessionSchema