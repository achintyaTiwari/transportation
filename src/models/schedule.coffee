uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

ScheduleSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  service_code: {
    type: String
    unique: true
    uppercase: true
    required: true
  }

  route: {
    type: String
    ref: 'Route'
    required: true
  }

  depart_at: {
    type: String
    required: true
  }

  arrive_at: {
    type: String
    required: true
  }

  direction: {
    type: String
    enum: ['UP', 'DOWN']
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
      _.omit(doc, ['_id', '__v', 'created_at', 'updated_at'])
  }
})

ScheduleSchema.plugin(deepPopulator)

module.exports = ScheduleSchema