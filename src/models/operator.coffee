uuid = require 'uuid'
slug = require 'slugg'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

OperatorSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  name: {
    type: String
    required:true
  }

  name_slug: {
    type: String
    unique: true
  }

  home_state: {
    type: String
    ref: 'State'
  }

  operating_states: [{
    type: String
    ref: 'State'
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
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v', 'name_slug'])
  }
})

OperatorSchema.index({name_slug: true}, {unique: true})

OperatorSchema.pre('save', (next)->
  if @isModified('name') or @isNew
    @name_slug = slug(@name)
  next()
)

OperatorSchema.plugin(deepPopulator)

module.exports = OperatorSchema