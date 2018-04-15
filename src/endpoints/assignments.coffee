express = require 'express'
router = express.Router()

router.param 'assignmentId', (req, res, next, id)->
  Q().then(->
    db.models.Assignment.findOne({_id: id}).deepPopulate([
      'operator', 'vehicle', 'vehicle.depot', 'conductor', 'driver', 'schedules', 'schedules.route',
      'schedules.route.depot', 'schedules.route.service_type', 'schedules.route.stops',
      'schedules.route.stops.stop'
    ])
  ).then((assignment)-> 
    if not assignment
      res.notFound()
    else
      req.assignment = assignment
      next()
  ).catch(next).done()

###
@api {GET} /assignments List
@apiName List
@apiGroup Assignments

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiParam {String} abstract_id
@apiParam {String} operator_id
@apiParam {String} driver_id
@apiParam {String} conductor_id
@apiParam {String} vehicle_id
@apiParam {String} device_id
@apiParam {String} schedule_id
@apiParam {String=active,inactive} status

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of assignment objects
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OngoingAssignmentFound
@apiError (Error400) {String} OperatorNotFound
@apiError (Error400) {String} ConductorNotFound
@apiError (Error400) {String} VehicleNotFound
@apiError (Error400) {String} ScheduleMismatch
@apiError (Error400) {String} DeviceNotFound
@apiError (Error400) {String} MongoError 
@apiError (Error404) {String} NotFound
###
router.get '/', (req, res, next)->
  Q().then(->
    query = {}
    if req.query.abstract_id then query.abstract_id = req.query.abstract_id
    if req.query.operator_id then query.operator = req.query.operator_id
    if req.query.conductor_id then query.conductor = req.query.conductor_id
    if req.query.driver_id then query.driver = req.query.driver_id
    if req.query.device_id then query.device = req.query.device_id

    switch (req.query.status or '').toUpperCase()
      when 'ACTIVE' then query.status = CONST.STATUS.ACTIVE
      when 'INACTIVE' then query.status = CONST.STATUS.INACTIVE

    db.models.Assignment.find(query).deepPopulate([
      'operator', 'vehicle', 'vehicle.depot', 'conductor', 'driver', 'schedules', 'schedules.route',
      'schedules.route.depot', 'schedules.route.service_type', 'schedules.route.stops',
      'schedules.route.stops.stop'
    ])
  ).then((assignments)->
    #FIXME:
    if req.query.device_id then assignments = _.first(assignments)
    res.success(assignments)
  ).catch(next).done()

###
@api {GET} /assignments/:assignmentId Get
@apiName Get
@apiGroup Assignments

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed assignment object
###
router.get '/:assignmentId', (req, res, next)->
  Q(req.assignment).then((assignment)->
    # TODO: orders should be part of waybill, check commit 5e0b7f8
    res.success(assignment)
  ).catch(next).done()

###
@api {POST} /assignments Create
@apiName Create
@apiGroup Assignments

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiParam {String} abstract_id
@apiParam {String} operator_id
@apiParam {String} conductor_id
@apiParam {String} driver_id
@apiParam {String} vehicle_id
@apiParam {String} device_id
@apiParam {Array[schedule.id]} schedules_ids
@apiParam {Boolean} repeats

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new assignment object
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['operator_id', 'driver_id', 'conductor_id', 'vehicle_id', 'device_id', 'schedule_ids'])
      return Q.reject(ERROR.InvalidRequest)
    else if not _. isArray(req.body.schedule_ids)
       return Q.reject(ERROR.InvalidRequest)

    req.body.schedule_ids = _.uniq(req.body.schedule_ids)

    [
      db.models.Operator.findOne({_id: req.body.operator_id, status: CONST.STATUS.ACTIVE})
      db.models.User.findOne({_id: req.body.conductor_id, type: 'CONDUCTOR', status: CONST.STATUS.ACTIVE})
      db.models.User.findOne({_id: req.body.driver_id, status: CONST.STATUS.ACTIVE})
      db.models.Vehicle.findOne({_id: req.body.vehicle_id, status: CONST.STATUS.ACTIVE})
      db.models.Device.findOne({_id: req.body.device_id, status: CONST.STATUS.ACTIVE})
      db.models.Schedule.find({_id: {'$in': _.uniq(req.body.schedule_ids)}, status: CONST.STATUS.ACTIVE})
      db.models.Assignment.find({conductor: req.body.conductor_id, status: CONST.STATUS.ACTIVE})
    ]
  ).spread((operator, conductor, driver, vehicle, device, schedules, ongoing_assignment)->
    if not operator then return Q.reject(ERROR.OperatorNotFound)
    if not conductor then return Q.reject(ERROR.ConductorNotFound)
    if not vehicle then return Q.reject(ERROR.VehicleNotFound)
    if not schedules or schedules.length isnt req.body.schedule_ids.length then return Q.reject(ERROR.ScheduleMismatch)
    if not device then return Q.reject(ERROR.DeviceNotFound)

    if not _.isEmpty(ongoing_assignment) and not req.query.ignore_ongoing then return Q.reject(ERROR.OngoingAssignmentFound)

    assignment = new db.models.Assignment({
      operator: operator
      conductor: conductor
      driver: driver
      vehicle: vehicle
      device: device
      schedules: schedules
      abstract_id: req.body.abstract_id
      repeats: req.body.repeats
    })
    assignment.save()
  ).then((assignment)->
    modules.push.toDevices(assignment.device.token, {
      action: "WAYBILL_CREATED"
      id: assignment.id
    })
    res.success({id: assignment.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {DELETE} /assignments/:assignmentId Delete
@apiName Delete
@apiGroup Assignments

@apiPermission Admin
@apiHeader {String} Authorization Session Token
@apiSuccess {Boolean} status true
###
router.delete '/:assignmentId', (req, res, next)->
  Q(req.assignment).then((assignment)->
    assignment.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router