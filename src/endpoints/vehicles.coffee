express = require 'express'
router = express.Router()

router.param 'vehicleId', (req, res, next, id)->
  Q().then(->
    db.models.Vehicle.findOne({_id: id})
  ).then((vehicle)->
    if not vehicle
      res.notFound()
    else
      req.vehicle = vehicle
      next()
  ).catch(next).done()

###
@api {GET} /vehicles List
@apiName List
@apiGroup Vehicles

@apiParam {String} operator_id
@apiParam {String} depot_id
@apiParam {String} reg_number
@apiParam {String=active,inactive} status

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of vehicle objects
###
router.get '/', (req, res, next)->
  Q().then(->
    query = {}
    if req.query.operator_id then query.operator = req.query.operator_id
    if req.query.depot_id then query.depot = req.query.depot_id
    if req.query.reg_number then query.reg_number = req.query.reg_number

    switch (req.query.status or '').toUpperCase()
      when 'ACTIVE' then query.status = CONST.STATUS.ACTIVE
      when 'INACTIVE' then query.status = CONST.STATUS.INACTIVE
 
    db.models.Vehicle.find(query)
  ).then((vehicles)->
    console.log(vehicles)
    res.success(vehicles)
  ).catch(next).done()

###
@api {GET} /vehicles/:vehicleId Get
@apiName Get
@apiGroup Vehicles

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed vehicle object
###
router.get '/:vehicleId', (req, res, next)->
  res.success(req.vehicle)

###
@api {POST} /vehicles Create
@apiName Create
@apiGroup Vehicles

@apiParam {String} operator_id
@apiParam {String} depot_id
@apiParam {String} reg_number

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new vehicle object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OperatorNotActive
@apiError (Error400) {String} DepotNotFound
@apiError (Error400) {String} DepotNotActive
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['operator_id', 'depot_id', 'reg_number'])
      return Q.reject(ERROR.InvalidRequest)
    [
      db.models.Operator.findOne({ _id: req.body.operator_id })
      db.models.Depot.findOne({ _id: req.body.depot_id })
    ]
  ).spread((operator, depot)->
    if not operator then return Q.reject(ERROR.OperatorNotFound)
    else if operator.status isnt CONST.STATUS.ACTIVE then return Q.reject(ERROR.OperatorNotActive)
    if not depot then return Q.reject(ERROR.DepotNotFound)
    else if depot.status isnt CONST.STATUS.ACTIVE then return Q.reject(ERROR.DepotNotActive)
    vehicle = new db.models.Vehicle({
      operator: operator
      depot: depot
      reg_number: req.body.reg_number
      capacity: req.body.capacity
    })
    vehicle.save()
  ).then((vehicle)->
    res.success({id: vehicle.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /vehicles/:vehicleId Update
@apiName Update
@apiGroup Vehicles

@apiParam {String} capacity

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated vehicle object
###
router.post '/:vehicleId', (req, res, next)->
  Q(req.vehicle).then((vehicle)->
    _.extend(vehicle, _.pick(req.body, [
      'capacity'
    ]))
    vehicle.save()
  ).then((vehicle)->
    res.success(vehicle)
  ).catch(next).done()

###
@api {DELETE} /vehicles/:vehicleId Delete
@apiName Delete
@apiGroup Vehicles

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:vehicleId', (req, res, next)->
  Q(req.vehicle).then((vehicle)->
    vehicle.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router