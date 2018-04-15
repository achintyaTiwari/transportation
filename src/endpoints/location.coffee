express = require 'express'
router = express.Router()

###
@api {GET} /location Query
@apiName Query
@apiGroup Location

@apiParam {String} device_id
@apiParam {String} schedule_id
@apiParam {Integer} limit[1]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {Object} data.geo
@apiSuccess {Object} data.geo.type
@apiSuccess {Array} data.geo.coordinates
@apiSuccess {Integer} data.speed
@apiSuccess {Integer} data.accuracy
@apiSuccess {Integer} data.created_at
@apiSuccess {Integer} data.reported_at
@apiError (Error400) {String} InvalidRequest
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.device_id then return Q.reject(ERROR.InvalidRequest)
    limit = parseInt(req.query.limit or 1)

    db.models.Location.find({device: req.query.device_id}).sort('-reported_at').limit(limit)
  ).then((locations)->
    res.success(locations)
  ).catch(next).done()

###
@api {POST} /location Reporting
@apiName Report
@apiGroup Location

@apiParam {String} device_id
@apiParam {String} schedule_id
@apiParam {String} lat
@apiParam {String} lon
@apiParam {String} speed
@apiParam {String} accuracy
@apiParam {String} bearing
@apiParam {String} timestamp

@apiSuccess {Boolean} status true
@apiError (Error400) {String} InvalidRequest
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['device_id', 'lat', 'lon', 'accuracy', 'timestamp'])
      return Q.reject(ERROR.InvalidRequest)

    # TODO: verify the authenticity of the data / request
    location = new db.models.Location({
      device: req.body.device_id
      geo: {
        coordinates: [req.body.lon, req.body.lat]
      }
      speed: req.body.speed
      accuracy: req.body.accuracy
      created_at: moment(parseInt(req.body.timestamp))
    })
    if req.body.service_id then location.service_id = req.body.service_id

    location.save()
  ).then((location)->
    res.success()
  ).catch(next).done()

module.exports = router