express = require 'express'
router = express.Router()

router.param 'fareId', (req, res, next, id)->
  Q().then(->
    db.models.Fare.findOne({_id: id})
  ).then((fare)->
    if not fare
      res.notFound()
    else
      req.fare = fare
      next()
  ).catch(next).done()

###
@api {GET} /fares List
@apiName List
@apiGroup Fares

@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of fare objects
@apiError (Error400) {String} InvalidRequest

###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }

    db.models.Fare.find(query)
  ).then((fares)->
    res.success(fares)
  ).catch(next).done()

###
@api {GET} /fares/:fareId Get
@apiName Get
@apiGroup Fares

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed fare object
###
router.get '/:fareId', (req, res, next)->
  res.success(req.fare)

###
@api {POST} /fares Create
@apiName Create
@apiGroup Fares

@apiParam {String} operator_id
@apiParam {String} name
@apiParam {String} code
@apiParam {String=luggage} type
@apiParam {Array[Object]} slabs[slab]
@apiParam (slab) {String} name
@apiParam (slab) {Number} value=0.0

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new fare object
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['code', 'operator_id']) or not _.isArray(req.body.slabs)
      return Q.reject(ERROR.InvalidRequest)

    fare = new db.models.Fare({
      operator: req.body.operator_id
      name: req.body.name
      code: req.body.code
      type: req.body.type
      slabs: req.body.slabs
    })
    fare.save()
  ).then((fare)->
    res.success({id: fare.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /fares/:fareId Update
@apiName Update
@apiGroup Fares

@apiParam {String} name
@apiParam {String} code
@apiParam {String=luggage} type
@apiParam {Array[Object]} slabs[slab]
@apiParam (slab) {String} name
@apiParam (slab) {Number} value=0.0

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated fare object
###
router.post '/:fareId', (req, res, next)->
  Q(req.fare).then((fare)->
    _.extend(fare, _.pick(req.body, [
      'name', 'code', 'type', 'slabs'
    ]))
    fare.save()
  ).then((fare)->
    res.success(fare)
  ).catch(next).done()

###
@api {DELETE} /fares/:fareId Delete
@apiName Delete
@apiGroup Fares

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:fareId', (req, res, next)->
  Q(req.fare).then((fare)->
    fare.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router