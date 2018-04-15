express = require 'express'
router = express.Router()

router.param 'stopId', (req, res, next, id)->
  Q().then(->
    db.models.Stop.findOne({_id: id}).deepPopulate(['state'])
  ).then((stop)->
    if not stop
      res.notFound()
    else
      req.stop = stop
      next()
  ).catch(next).done()

###
@api {GET} /stops List
@apiName List
@apiGroup Stops

@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of stop objects
@apiError (Error400) {String} InvalidRequest
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
    }
    db.models.Stop.find(query).deepPopulate(['state'])
  ).then((stops)->
    res.success(stops)
  ).catch(next).done()

###
@api {GET} /stops/:stopId Get
@apiName Get
@apiGroup Stops

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed route object
###
router.get '/:stopId', (req, res, next)->
  res.success(req.stop)

###
@api {POST} /stops Create
@apiName Create
@apiGroup Stops

@apiParam {String} operator_id
@apiParam {String} code
@apiParam {String} name
@apiParam {String} regional_name
@apiParam {String} place_id
@apiParam {String} lat
@apiParam {String} lon
@apiParam {String} state_id

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new stop object
@apiError (Error400) {String} InvalidRequest
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['operator_id', 'code', 'name', 'place_id', 'lat', 'lon', 'state_id'])
      return Q.reject(ERROR.InvalidRequest)

    stop = new db.models.Stop({
      operator: req.body.operator_id
      code: req.body.code
      name: req.body.name
      regional_name: req.body.regional_name
      place_id: req.body.place_id
      state: req.body.state_id
      location: {
        coordinates: [req.body.lon, req.body.lat]
      }
    })
    stop.save()
  ).then((stop)->
    res.success({id: stop.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /stops/:stopId Update
@apiName Update
@apiGroup Stops

@apiParam {String} code
@apiParam {String} name
@apiParam {String} regional_name
@apiParam {String} place_id
@apiParam {String} lat
@apiParam {String} lon
@apiParam {String} state_id

@apiSuccess {Boolean} status true
@apiSuccess {Object} data updated Stop object
###
router.post '/:stopId', (req, res, next)->
  Q(req.stop).then((stop)->
    _.extend(stop, _.pick(req.body, [
      'code', 'name', 'regional_name', 'place_id'
    ]))

    if req.body.state_id then stop.state = req.body.state_id
    if req.body.lat and req.body.lon
      stop.location.coordinates = [req.body.lon, req.body.lat]
    stop.save()
  ).then((stop)->
    res.success(stop)
  ).catch(next).done()

###
@api {DELETE} /stops/:stopId Delete
@apiName Delete
@apiGroup Stops

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:stopId', (req, res, next)->
  Q(req.stop).then((stop)->
    stop.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router