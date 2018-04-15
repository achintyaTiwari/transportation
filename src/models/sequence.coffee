uuid = require 'uuid'
Schema = require('mongoose').Schema

SequenceSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  val: {
    type: Number
    required: true
    default: 0
  }

}, {
  toObject: {
    virtuals: true
    transform: (instance, doc)->
      i = doc.val
      doc.val_alphanumeric = "#{ getChar(i, 5) }#{ getChar(i, 4) }#{ getChar(i, 3) }#{ getChar(i, 2) }#{ getChar(i, 1) }#{ getChar(i, 0) }"
      _.omit(doc, ['_id', '__v'])
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      i = doc.val
      doc.val_alphanumeric = "#{ getChar(i, 5) }#{ getChar(i, 4) }#{ getChar(i, 3) }#{ getChar(i, 2) }#{ getChar(i, 1) }#{ getChar(i, 0) }"
      _.omit(doc, ['_id', '__v'])
  }
})

SequenceSchema.statics.getNext = (id)->
  return @findOneAndUpdate({_id: id}, {$inc: { val: 1 }}, {new: true, upsert: true}).then((seq)->
    return seq
  )

getChar = (val, pos)->
  switch pos
    when 0, 1, 2, 3 then Math.floor((val / Math.pow(10, pos)) % 10)
    when 4 then String.fromCharCode(Math.floor(((val / (Math.pow(26, 0) * Math.pow(10, pos - 1))) % 26) + "A".charCodeAt(0)))
    when 5 then String.fromCharCode(Math.floor(((val / (Math.pow(26, 1) * Math.pow(10, pos - 2))) % 26) + "A".charCodeAt(0)))

module.exports = SequenceSchema
