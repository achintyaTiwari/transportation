Schema = require('mongoose').Schema

DeviceStatusSchema = new Schema({

  device: {
    type: String
    ref: 'Device'
    required: true
  }

  battery: {
    status: {
      type: Number
    }
    temperature: {
      type: Number
    }
    level: {
      type: Number
    }
  }

  created_at: {
    type: Date
    default: Date.now
  }

  reported_at: {
    type: Date
    default: Date.now
  }
}, {
  toObject: {
    virtuals: true
  }
  toJSON: {
    virtuals: true
    transform: (instance, doc)->
      doc.id = doc._id
      if doc.battery.status?
        doc.battery.status = _.findKey({
          DISCHARGING: 0
          CHARGING_AC: 1
          CHARGING_USB: 2
          CHARGING_WIRELESS: 4
        }, (r)-> r is doc.battery.status)

      _.omit(doc, ['_id', '__v'])
  }
})

DeviceStatusSchema.index({'device': 1})

module.exports = DeviceStatusSchema