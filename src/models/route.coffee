uuid = require 'uuid'
mongoose = require('mongoose')
deepPopulator = require('mongoose-deep-populate')(mongoose)
Schema = mongoose.Schema

RouteSchema = new Schema({

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

  depot: {
    type: String
    ref: 'Depot'
    required: true
  }

  name: {
    type: String
    required: true
  }

  service_type: {
    type: String
    ref: 'ServiceType'
    required: true
  }

  fare_type: {
    type: String
    enum: ['STAGE', 'MATRIX']
    uppercase: true
    required: true
  }

  stops: [

    seq: {
      type: Number
      required: true
    }

    stop: {
      type: String
      ref: 'Stop'
      required: true
    }

    is_stage: {
      type: Boolean
      default: false
    }

    arrive_in_mins: {
      type: Number
      required: true
    }

    depart_in_mins: {
      type: Number
      required: true
    }

    toll_plaza_count: {
      type: Number
      default: 0
    }

    distance: {
      type: Number
      default: 0
    }

    fare: {
      type: [Number]
      required: true
    }

  ]

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
      doc.stops = _.map(doc.stops, (sd)->
        sd.id = sd._id
        delete sd._id
        return sd
      )
      doc.status = _.findKey(CONST.STATUS, (r)-> r is doc.status)
      _.omit(doc, ['_id', '__v', 'created_at', 'updated_at'])
  }
})

RouteSchema.index({name: true, operator: true}, {unique: true})

RouteSchema.plugin(deepPopulator)

module.exports = RouteSchema