express = require 'express'
router = express.Router()

router.param 'scheduleId', (req, res, next, id)->
  Q().then(->
    db.models.Schedule.findOne({_id: id}).deepPopulate([
      'route', 'route.depot', 'route.service_type', 'route.stops', 'route.stops.stop'
    ])
  ).then((schedule)->
    if not schedule
      res.notFound()
    else
      req.schedule = schedule
      next()
  ).catch(next).done()

###
@api {GET} /schedules List
@apiName List
@apiGroup Schedules

@apiParam {String} operator_id
@apiParam {String} route_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of schedule objects
###
router.get '/', (req, res, next)->
  Q().then(->
    query = {
      status: CONST.STATUS.ACTIVE
    }
    if req.query.route_id then query.route = req.query.route_id
#    if req.query.operator_id then query.operator = req.query.operator_id

    db.models.Schedule.find(query).deepPopulate([
      'route', 'route.depot', 'route.service_type', 'route.stops', 'route.stops.stop'
    ])
  ).then((schedules)->
    res.success(schedules)
  ).catch(next).done()

###
@api {GET} /schedules/:scheduleId Get
@apiName Get
@apiGroup Schedules

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed schedule object
###
router.get '/:scheduleId', (req, res, next)->
  res.success(req.schedule)

###
@api {POST} /schedules Create
@apiName Create
@apiGroup Schedules

@apiParam {String} service_code
@apiParam {String} route_id
@apiParam {String} depart_at
@apiParam {String} arrive_at
@apiParam {String=up,down} direction

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new schedule object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} RouteNotFound

###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['service_code', 'route_id', 'depart_at', 'arrive_at', 'direction'])
      return Q.reject(ERROR.InvalidRequest)

    db.models.Route.findOne({
      _id: req.body.route_id
      status: CONST.STATUS.ACTIVE
    })
  ).then((route)->
    if not route then return Q.reject(ERROR.RouteNotFound)

    schedule = new db.models.Schedule({
      service_code: req.body.service_code
      route: route
      depart_at: req.body.depart_at
      arrive_at: req.body.arrive_at
      direction: req.body.direction
    })
    schedule.save()
  ).then((schedule)->
    res.success({id: schedule.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()


###
@api {POST} /schedules/:scheduleId Update
@apiName Update
@apiGroup Schedules

@apiParam {String} service_code
@apiParam {String} route_id
@apiParam {String} depart_at
@apiParam {String} arrive_at
@apiParam {String=up,down} direction

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated schedule object
###
router.post '/:scheduleId', (req, res, next)->
  Q(req.schedule).then((schedule)->
    _.extend(schedule, _.pick(req.body, [
      'service_code', 'depart_at', 'arrive_at', 'direction'
    ]))

    if req.body.route_id then schedule.route = req.body.route_id

    schedule.save()
  ).then((schedule)->
    res.success(schedule)
  ).catch(next).done()

###
@api {DELETE} /schedules/:scheduleId Delete
@apiName Delete
@apiGroup Schedules

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:scheduleId', (req, res, next)->
  Q(req.schedule).then((schedule)->
    schedule.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router