express = require 'express'
router = express.Router()

router.param 'productId', (req, res, next, id)->
  Q().then(->
    db.models.Product.findOne({_id: id}).deepPopulate(['servicetypes'])
  ).then((product)->
    if not product
      res.notFound()
    else
      req.product = product
      next()
  ).catch(next).done()

###
@api {GET} /products List
@apiName List
@apiGroup Products

@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of product objects
@apiError (Error400) {String} InvalidRequest
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
    }

    db.models.Product.find(query).deepPopulate(['servicetypes'])
  ).then((products)->
    console.log(products)
    res.success(products)
  ).catch(next).done()

###
@api {GET} /products/:productId Get
@apiName Get
@apiGroup Products

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed product object
###
router.get '/:productId', (req, res, next)->
 Q(req.product).then((product)->
    # TODO: orders should be part of waybill, check commit 5e0b7f8
  res.success(product)
 ).catch(next).done()

###
@api {POST} /products Create
@apiName Create
@apiGroup Products

@apiParam {String} name
@apiParam {String} desc
@apiParam {Number} price
@apiParam {String} operator_id
@apiParam {Array} servicetype_ids
@apiParam {Number} validity
@apiParam {String=day,journey,calender_month} [validity_type=day]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new product object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} MissingValidityType
@apiError (Error400) {String} OperatorNotFound
@apiError (Error400) {String} OperatorNotActive

###
router.post '/', (req, res, next)->
  Q().then(->
    validity_type = (req.body.validity_type or 'days').toLowerCase()
    if not req.body.name or not req.body.price then return Q.reject(ERROR.InvalidRequest)
    if not _.includes(['day', 'journey', 'calender_month'], validity_type)
      return Q.reject(ERROR.MissingValidityType)

    switch validity_type
      when 'day' then req.body.validity_type = CONST.VALIDITY_TYPE.DAY
      when 'journey' then req.body.validity_type = CONST.VALIDITY_TYPE.JOURNEY
      when 'calender_month' then req.body.validity_type = CONST.VALIDITY_TYPE.CALENDER_MONTH

    db.models.Operator.findOne({
      _id: req.body.operator_id
    })
  ).then((operator)->
    if not operator then return Q.reject(ERROR.OperatorNotFound)
    if operator.status isnt CONST.STATUS.ACTIVE then return Q.reject(ERROR.OperatorNotActive)
    product = new db.models.Product({
      name: req.body.name
      desc: req.body.desc
      price: req.body.price
      validity: req.body.validity
      validity_type: req.body.validity_type
      operator: operator
      servicetypes: req.body.servicetype_ids
    })
    product.save()
  ).then((product)->
    res.success({id: product.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /products/:productId Update
@apiName Update
@apiGroup Products

@apiParam {String} name
@apiParam {String} desc
@apiParam {Number} price Price without decimal places. eg: 99.99 should be passed as 9999
@apiParam {String} operator_id
@apiParam {Array} servicetype_ids
@apiParam {Number} validity
@apiParam {String=days,boardings,calender_month} [validity_type=days]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated product object
@apiError (Error400) {String} MissingValidityType
###
router.post '/:productId', (req, res, next)->
  Q(req.product).then((product)->
    if req.body.validity_type
      validity_type = req.body.validity_type.toLowerCase()
      if not _.includes(['day', 'journey', 'calender_month'], validity_type)
        return Q.reject(ERROR.MissingValidityType)

      switch validity_type
        when 'day' then req.body.validity_type = CONST.VALIDITY_TYPE.DAY
        when 'journey' then req.body.validity_type = CONST.VALIDITY_TYPE.JOURNEY
        when 'calender_month' then req.body.validity_type = CONST.VALIDITY_TYPE.CALENDER_MONTH

    _.extend(product, _.pick(req.body, [
      'name'
      'desc'
      'price'
      'validity'
      'validity_type'
    ]))

    if req.body.servicetype_ids then product.servicetypes = req.body.servicetype_ids

    product.save()
  ).then((product)->
    res.success(product)
  ).catch(next).done()

###
@api {DELETE} /products/:productId Delete
@apiName Delete
@apiGroup Products

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:productId', (req, res, next)->
  Q(req.product).then((product)->
    product.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router