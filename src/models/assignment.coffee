uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

AssignmentSchema = new Schema({

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

  driver: {
    type: String
    ref: 'User'
  
  }

  conductor: {
    type: String
    ref: 'User'
  }

  device: {
    type: String
    ref: 'Device'
    required: true
  }

  vehicle: {
    type: String
    ref: 'Vehicle'
    required: true
  }

  abstract_id: {
    type: String
  }

  schedules: [{
    type: String
    ref: 'Schedule'
    required: true
  }]

  order_seq_start: {
    type: Number
  }

  repeats: {
    type: Boolean
    default: false
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
      _.omit(doc, ['_id', '__v',])
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v',])
  }
})

AssignmentSchema.pre('save', (next)->
  if @isModified('device') or @isNew
    db.models.Sequence.getNext(@device.id).then((seq)=>
      @order_seq_start = seq.val
      next()
    )
  else return next()
)

AssignmentSchema.plugin(deepPopulator)

module.exports = AssignmentSchema