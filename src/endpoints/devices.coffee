express = require 'express'
router = express.Router()

router.param 'deviceId', (req, res, next, id)->
  Q().then(->
    db.models.Device.findOne({_id: id})
  ).then((device)->
    if not device
      res.notFound()
    else
      req.device = device
      next()
  ).catch(next).done()

###
@api {GET} /devices List
@apiName List
@apiGroup Devices

@apiParam {String} operator_id
@apiParam {String} depot_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of registered devices
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }
    if req.query.depot_id then query.depot = req.query.depot_id

    db.models.Device.find(query)
  ).then((devices)->
    res.success(devices)
  ).catch(next).done()

###
@api {GET} /devices/:deviceId Get
@apiName Get
@apiGroup Devices

@apiSuccess {Boolean} status true
@apiSuccess {Object} data registered device object
###
router.get '/:deviceId', (req, res, next)->
  res.success(req.device)

###
@api {POST} /devices Create
@apiName Create
@apiGroup Devices

@apiParam {String} application_id
@apiParam {String} operator_id
@apiParam {String} depot_id
@apiParam {String} imei
@apiParam {String} mac
@apiParam {String} uuid
@apiParam {String} imei
@apiParam {String} token FCM token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data registered device object
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['operator_id', 'application_id', 'uuid', 'imei'])
      return Q.reject(ERROR.InvalidRequest)

    device = new db.models.Device({
      application: req.body.application_id
      operator: req.body.operator_id
      depot: req.body.depot_id
      imei: req.body.imei
      uuid: req.body.uuid
      mac: req.body.mac
      token: req.body.token
    })
    device.save()
  ).then((device)->
    res.success(device, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /devices/:deviceId Update
@apiName Update
@apiGroup Devices

@apiParam {String} token FCM token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data registered device object
###
router.post '/:deviceId', (req, res, next)->
  Q(req.device).then((device)->
    if req.body.token then device.token = req.body.token
    if req.body.meta_data then device.meta_data = req.body.meta_data
    device.save()
  ).then((device)->
    res.success(device)
  ).catch(next).done()

###
@api {POST} /:deviceId/notification Notification
@apiName Notification
@apiGroup Devices

@apiParam {Object} payload

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {Object} data.id Id of the newly created notification request
###
router.post '/:deviceId/notification', (req, res, next)->
  Q(req.device).then((device)->
    if not req.body.payload then return Q.reject({name: 'MissingPayload'})
    if not device.token then return Q.reject({name: 'InvalidToken'})
    modules.push.send(device.token, req.body.payload)
  ).then((result)->
    db.models.Notification.log(CONST.NOTIFICATION_TYPE.PUSH, req.device.id, req, result.multicast_id)
  ).then((notification)->
    res.success({id: notification.id}, HTTP_STATUS_CODES.ACCEPTED)
  ).catch(next).done()

###
@api {POST} /devices/:deviceId/status Reporting
@apiName Reporting
@apiGroup Devices

@apiParam {String} operator_id
@apiParam {Array} updates[update]
@apiParam {String} update.type supported types trip, transaction, location, device
@apiParam {Object} update.data trip{id, schedule_id, hash, lat, lon, status, timestamp}
                               transaction{id, type, product_id, amount, payment_method, payment_id, payment_processor, timestamp}
                               location{lat, lon, acc, timestamp}
                               device{battery_status, battery_remaining, temperature, data_connectivity_status, wifi_status, bluetooth_status}

@apiSuccess {Boolean} status true
@apiSuccess {Object} data registered device object
###
router.post '/:deviceId/status', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['updates'])
      return Q.reject(ERROR.InvalidRequest)

    updatesPromises = _.map(req.body.updates, (update)->
      if not update.update_type then return null
      if update.update_type is "trip"
        if update.status is 'started'
          trip = new db.models.Trip({
            _id: update.id
            waybill: update.waybill_id
            schedule: update.schedule_id
            hash: update.hash
            secret_key: new Buffer(rand.generate(CONST.SECRET_KEY_LENGTH)).toString(CONST.BASE64)
            start: {
              location: [update.lon, update.lat]
              datetime: moment(update.timestamp)
            }
            status: CONST.TRIP_STATUS.STARTED
          })
          trip.save()
        else if update.status is 'completed'
          db.models.Trip.findOneAndUpdate({_id: update.id}, {
            end: {
              location: [update.lon, update.lat]
              datetime: moment(update.timestamp)
            }
            status: CONST.TRIP_STATUS.COMPLETED
          })
      else if update.update_type is "transaction"
        order = new db.models.Order({
          user: update.user_id or 'UNKNOWN'
          operator: req.body.operator_id
          seq: req.body.seq
          channel: {
            id: req.device.id
          }
          trip: update.trip_id
          schedule: update.schedule_id
          amount: update.amount
          type: update.type
          payment: {
            id: update.payment_id
            method: update.payment_method.toUpperCase()
          }
        })

        if update.type is 'pass'
          order.product = update.product_id
          order.validity = update.validity
          order.validity_type = update.validity_type
        else if update.type is 'passenger_ticket'
          order.product = {
            journey: {
              from: req.body.from
              to: req.body.to
              adults: req.body.adults
              children: req.body.children
            }
          }

        order.save()
      else if update.update_type is "location"
        location = new db.models.Location({
          device: req.device
          geo: {
            coordinates: [update.lon, update.lat]
          }
          speed: update.speed
          accuracy: update.accuracy
          created_at: moment(parseInt(update.timestamp))
        })
        location.save()
      else if update.update_type is "device_status"
        deviceUpdatePromises = []

        deviceStatus = new db.models.DeviceStatus({
          device: req.device
          battery: {
            level: update.battery_level
            temperature: update.battery_temperature
            status: update.battery_status
          }
          created_at: moment(parseInt(update.timestamp))
        })
        deviceUpdatePromises.push(deviceStatus.save())

        if update.current_seq
          seqUpdatePromise = db.models.Sequence.findOneAndUpdate({_id: req.device}, {val: update.current_seq},
            {new: true, upsert: true})
          deviceUpdatePromises.push(seqUpdatePromise)

        Q.all(deviceUpdatePromises)
    )
    Q.all(updatesPromises)
  ).then((updates)->
    res.success(null, HTTP_STATUS_CODES.ACCEPTED)
  ).catch(next).done()

###
@api {GET} /devices/:deviceId/status Status
@apiName Status
@apiGroup Devices

@apiParam {Integer} limit[1]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data registered device object
###
router.get '/:deviceId/status', (req, res, next)->
  Q().then(->
    limit = parseInt(req.query.limit or 1)

    [
      db.models.DeviceStatus.find({device: req.device.id}).sort('-reported_at').limit(limit)
      db.models.Location.find({device: req.device.id}).sort('-reported_at').limit(limit)
    ]
  ).spread((updates, locations)->
    device = req.device.toObject()
    device.status_updates = updates
    device.locations_updates = locations
    res.success(device)
  ).catch(next).done()

###
@api {DELETE} /devices/:deviceId Delete
@apiName Delete
@apiGroup Devices

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:deviceId', (req, res, next)->
  Q(req.device).then((device)->
    device.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router