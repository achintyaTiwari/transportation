uuid = require 'uuid'
rand = require 'randomstring'
bcrypt = require 'bcryptjs'
md5 = require 'md5'
gravatar = require 'gravatar'
Schema = require('mongoose').Schema

UserSchema = new Schema({

  _id: {
    type: String
    unique: true
    default: uuid.v4
  }

  first_name: {
    type: String
  }

  last_name: {
    type: String
  }

  mobile_number: {
    type: Number
    required: true
  }

  alt_mobile_numbers: [{
    type: Number
  }]

  email_address: {
    type: String
  }

  password: {
    type: String
    default: rand.generate(8)
  }

  pin: {
    type: String
    default: '123456'
  }

  otp: {
    type: String
  }

  avatar: {
    type: String
  }

  operator: {
    type: String
    ref: 'Operator'
  }

  preferences: {
    type: Schema.Types.Mixed
  }

  type: {
    type: String
    enum: ['ADMIN', 'OPERATOR_ADMIN', 'DEPOT_ADMIN', 'CONDUCTOR', 'DRIVER', 'COMMUTER']
    uppercase: true
    required: true
  }

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
      _.omit(doc, ['_id', '__v', 'password', 'otp', 'status', 'created_at', 'updated_at'])
  }
})

UserSchema.index({mobile_number: true, type: true}, {unique: true})

UserSchema.pre('save', (next)->
  if @isModified('password') or @isNew
    bcrypt.genSalt(10, (err, salt)=>
      if err then return next(err)
      bcrypt.hash(@password, salt, (err, hash)=>
        if err then return next(err)
        @password = hash
        next()
      )
    )
  else return next()
)

UserSchema.pre('save', (next)->
  if @isNew and not @avatar
    @avatar = gravatar.url(@email_address, {d: 'mm'}, true)

  if @isModified('pin') or @isNew
    @pin = md5(@pin)

  next()
)

UserSchema.methods.verifyPassword = (password)->
  Q.nfcall(bcrypt.compare, password, @password)

module.exports = UserSchema