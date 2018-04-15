express = require 'express'
router = express.Router()

router.param 'paymentMethodId', (req, res, next, id)->
  Q().then(->
    db.models.PaymentMethod.findOne({_id: id})
  ).then((paymentMethod)->
    if not paymentMethod
      res.notFound()
    else
      req.paymentMethod = paymentMethod
      next()
  ).catch(next).done()

###
@api {GET} /paymentMethods List
@apiName List
@apiGroup PaymentMethods

@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of payment method objects
@apiError (Error400) {String} InvalidRequest
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }

    db.models.PaymentMethod.find(query)
  ).then((paymentMethods)->
    res.success(paymentMethods)
  ).catch(next).done()

###
@api {GET} /paymentMethods/:paymentMethodId Get
@apiName Get
@apiGroup PaymentMethods

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed service object
###
router.get '/:paymentMethodId', (req, res, next)->
  res.success(req.paymentMethod)

###
@api {POST} /paymentMethods Create
@apiName Create
@apiGroup PaymentMethods

@apiParam {String} operator_id
@apiParam {String} name

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new payment method object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OperatorNotFound
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['name', 'operator_id']) then return Q.reject(ERROR.InvalidRequest)
    db.models.Operator.findOne({
      _id: req.body.operator_id
      status: CONST.STATUS.ACTIVE
    })
  ).then((operator)->
    if not operator then return Q.reject(ERROR.OperatorNotFound)
    paymentMethod = new db.models.PaymentMethod({
      operator: operator
      name: req.body.name
    })
    paymentMethod.save()
  ).then((paymentMethod)->
    res.success({id: paymentMethod.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /paymentMethods/:paymentMethodId Update
@apiName Update
@apiGroup PaymentMethods

@apiParam {String} name

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated payment method object
###
router.post '/:paymentMethodId', (req, res, next)->
  Q(req.paymentMethod).then((paymentMethod)->
    _.extend(paymentMethod, _.pick(req.body, [
      'name'
    ]))
    paymentMethod.save()
  ).then((paymentMethod)->
    res.success(paymentMethod)
  ).catch(next).done()

###
@api {DELETE} /paymentMethods/:paymentMethodId Delete
@apiName Delete
@apiGroup PaymentMethods

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiError (Error400) {String} InvalidRequest
###
router.delete '/:paymentMethodId', (req, res, next)->
  Q(req.paymentMethod).then((paymentMethod)->
    paymentMethod.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router