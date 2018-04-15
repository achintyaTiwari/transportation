express = require 'express'
router = express.Router()

router.param 'routeId', (req, res, next, id)->
  Q().then(->
    db.models.Route.findOne({_id: id}).deepPopulate(['depot', 'service_type', 'stops.stop'])
  ).then((route)->
    if not route
      res.notFound()
    else
      req.routeObj = route
      next()
  ).catch(next).done()

###
@api {GET} /routes List
@apiName List
@apiGroup Routes

@apiParam {String} operator_id
@apiParam {String} depot_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of route objects
@apiError (Error400) {String} InvalidRequest
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }
    if req.query.depot_id then query.depot = req.query.depot_id

    db.models.Route.find(query)
      .deepPopulate(['depot', 'service_type', 'stops.stop'])
  ).then((routes)->
    res.success(routes)
  ).catch(next).done()

###
@api {GET} /routes/:routeId Get
@apiName Get
@apiGroup Routes

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed route object
###
router.get '/:routeId', (req, res, next)->
  res.success(req.routeObj)

###
@api {POST} /routes Create
@apiName Create
@apiGroup Routes

@apiParam {String} name
@apiParam {String} operator_id
@apiParam {String} depot_id
@apiParam {String} service_type_id
@apiParam {String=stage,matrix} fare_type
@apiParam {Array[Stop]} stops
@apiParam {Number} stops.stop.seq
@apiParam {String} stops.stop.stop_id
@apiParam {Number} stops.stop.arrive_in_mins
@apiParam {Number} stops.stop.depart_in_mins
@apiParam {Array[Number]} stops.stop.fare
  For fare type of `stage`, array will contain a single element,
  For fare type `matrix`, array will contain `seq - 1` elements
@apiParam {Number} [stops.stop.toll_plaza_count=0]
@apiParam {Number} [stops.stop.distance=0]
@apiParam {Boolean} [stops.stop.is_stage=false]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new route object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OperatorNotFound
@apiError (Error400) {String} ServiceTypeNotFound

###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['name', 'operator_id', 'depot_id', 'service_type_id', 'fare_type'])
      return Q.reject(ERROR.InvalidRequest)

    # TODO: validate stops array to contain atleast 2 entries
    Q.all([
      db.models.Operator.findOne({
        _id: req.body.operator_id
        status: CONST.STATUS.ACTIVE
      })
      db.models.ServiceType.findOne({
        _id: req.body.service_type_id
        status: CONST.STATUS.ACTIVE
      })
    ])
  ).spread((operator, serviceType)->
    if not operator then return Q.reject(ERROR.OperatorNotFound)
    if not serviceType then return Q.reject(ERROR.ServiceTypeNotFound)

    stops = []
    if req.body.stops
      stops = _.map(req.body.stops, (stop)->
        if not hasRequiredParams(stop, ['stop_id', 'seq', 'arrive_in_mins', 'depart_in_mins', 'fare']) then return false
        return {
          seq: stop.seq
          stop: stop.stop_id
          arrive_in_mins: stop.arrive_in_mins
          depart_in_mins: stop.depart_in_mins
          is_stage: stop.is_stage or false
          toll_plaza_count: stop.toll_plaza_count or 0
          distance: stop.distance or 0
          fare: stop.fare
        }
      )

    route = new db.models.Route({
      name: req.body.name
      operator: req.body.operator_id
      depot: req.body.depot_id
      service_type: req.body.service_type_id
      fare_type: req.body.fare_type
      stops: _.compact(stops)
    })
    route.save()
  ).then((route)->
    res.success({id: route.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /routes/:routeId Update
@apiName Update
@apiGroup Routes

@apiParam {String} name
@apiParam {String} depot_id
@apiParam {String} service_type_id
@apiParam {String=stage,matrix} fare_type
@apiParam {Array[Stop]} stops
@apiParam {Number} stops.stop.seq
@apiParam {String} stops.stop.stop_id
@apiParam {Number} stops.stop.arrive_in_mins
@apiParam {Number} stops.stop.depart_in_mins
@apiParam {Array[Number]} stops.stop.fare
  For fare type of `stage`, array will contain a single element,
  For fare type `matrix`, array will contain `seq - 1` elements
@apiParam {Number} [stops.stop.toll_plaza_count=0]
@apiParam {Number} [stops.stop.distance=0]
@apiParam {Boolean} [stops.stop.is_stage=false]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated route object
###
router.post '/:routeId', (req, res, next)->
  Q(req.routeObj).then((route)->

    if req.body.name then route.name = req.body.name

    # TODO: validate these ref before we save it
    if req.body.service_type_id then route.service_type = req.body.service_type_id
    if req.body.depot_id then route.depot = req.body.depot_id
    if req.body.fare_type then route.fare_type = req.body.fare_type

    if req.body.stops
      route.stops = _.map(req.body.stops, (stop)->
        if not hasRequiredParams(stop, ['stop_id', 'seq', 'arrive_in_mins', 'depart_in_mins', 'fare']) then return false
        return {
          seq: stop.seq
          stop: stop.stop_id
          arrive_in_mins: stop.arrive_in_mins
          depart_in_mins: stop.depart_in_mins
          is_stage: stop.is_stage or false
          toll_plaza_count: stop.toll_plaza_count or 0
          distance: stop.distance or 0
          fare: stop.fare
        }
      )

    route.save()
  ).then((route)->
    res.success(route)
  ).catch(next).done()

###
@api {DELETE} /routes/:routeId Delete
@apiName Delete
@apiGroup Routes

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:routeId', (req, res, next)->
  Q(req.routeObj).then((route)->
    route.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router