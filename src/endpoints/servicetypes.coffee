express = require 'express'
router = express.Router()

router.param 'serviceTypeId', (req, res, next, id)->
  Q().then(->
    db.models.ServiceType.findOne({_id: id}).deepPopulate(['payment_methods'])
  ).then((serviceType)->
    if not serviceType
      res.notFound()
    else
      req.serviceType = serviceType
      next()
  ).catch(next).done()

###
@api {GET} /serviceTypes List
@apiName List
@apiGroup ServiceTypes

@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of service objects
@apiError (Error400) {String} InvalidRequest

###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest )

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }
    db.models.ServiceType.find(query).deepPopulate(['payment_methods'])
  ).then((serviceTypes)->
    res.success(serviceTypes)
  ).catch(next).done()

###
@api {GET} /serviceTypes/:serviceTypeId Get
@apiName Get
@apiGroup ServiceTypes

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed service type object
###
router.get '/:serviceTypeId', (req, res, next)->
  res.success(req.serviceType)

###
@api {POST} /serviceTypes Create
@apiName Create
@apiGroup ServiceTypes

@apiParam {String} operator_id
@apiParam {String} name
@apiParam {String} code
@apiParam {Number} seating_capacity
@apiParam {Number} basic_fare
@apiParam {Number} minimum_fare
@apiParam {Number} service_tax
@apiParam {Number} toll_charge
@apiParam {Number} cess
@apiParam {String} luggage_fare_id
@apiParam {Array[Number]} stage_fares[]
@apiParam {Number} stage_distance_in_kms
@apiParam {Number} stage_duration_in_mins
@apiParam {Number} round_off
@apiParam {Boolean} is_pass_allowed
@apiParam {Boolean} is_concession_allowed
@apiParam {Array} payment_methods[payment_method_id]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new service type object
@apiError (Error400) {String} OperatorNotFound
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['name', 'code', 'operator_id']) then return Q.reject(ERROR.InvalidRequest)
    db.models.Operator.findOne({
      _id: req.body.operator_id
      status: CONST.STATUS.ACTIVE
    })
  ).then((operator)->
    if not operator then return Q.reject(ERROR. OperatorNotFound)
    serviceType = new db.models.ServiceType({
      operator: operator
      code: req.body.code
      name: req.body.name
      seating_capacity: req.body.seating_capacity
      basic_fare: req.body.basic_fare
      minimum_fare: req.body.minimum_fare
      service_tax: req.body.service_tax
      toll_charge: req.body.toll_charge
      cess: req.body.cess
      luggage_fare: req.body.luggage_fare_id
      stage_fares: req.body.stage_fares
      stage_distance_in_kms: req.body.stage_distance_in_kms
      stage_duration_in_mins: req.body.stage_duration_in_mins
      is_pass_allowed: req.body.is_pass_allowed
      is_concession_allowed: req.body.is_concession_allowed
      payment_methods: req.body.payment_methods
    })
    serviceType.save()
  ).then((serviceType)->
    res.success({id: serviceType.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /serviceTypes/:serviceTypeId Update
@apiName Update
@apiGroup ServiceTypes

@apiParam {String} operator_id
@apiParam {String} name
@apiParam {String} code
@apiParam {Number} seating_capacity
@apiParam {Number} basic_fare
@apiParam {Number} minimum_fare
@apiParam {Number} service_tax
@apiParam {Number} toll_charge
@apiParam {Number} cess
@apiParam {String} luggage_fare_id
@apiParam {Array[Number]} stage_fares[]
@apiParam {Number} stage_distance_in_kms
@apiParam {Number} stage_duration_in_mins
@apiParam {Number} round_off
@apiParam {Boolean} is_pass_allowed
@apiParam {Boolean} is_concession_allowed
@apiParam {Array} payment_methods[payment_method_id]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated serviceType object
###
router.post '/:serviceTypeId', (req, res, next)->
  Q(req.serviceType).then((serviceType)->
    _.extend(serviceType, _.pick(req.body, [
      'name', 'code', 'seating_capacity', 'basic_fare', 'minimum_fare', 'service_tax', 'toll_charge', 'cess',
      'stage_fares', 'stage_distance_in_kms','stage_duration_in_mins','is_pass_allowed', 'is_concession_allowed',
      'payment_methods', 'round_off'
    ]))

    if req.bo dy.luggage_fare_id then serviceType.luggage_fare = req.body.luggage_fare_id
    serviceType.save()
  ).then((serviceType)->
    res.success(serviceType)
  ).catch(next).done()

###
@api {DELETE} /serviceTypes/:serviceId Delete
@apiName Delete
@apiGroup ServiceTypes

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:serviceTypeId', (req, res, next)->
  Q(req.serviceType).then((serviceType)->
    serviceType.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router