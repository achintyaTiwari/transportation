express = require 'express'
router = express.Router()

router.param 'operatorId', (req, res, next, id)->
  Q().then(->
    db.models.Operator.findOne({_id: id}).deepPopulate(['home_state', 'operating_states'])
  ).then((operator)->
    if not operator
      res.notFound()
    else
      req.operator = operator
      next()
  ).catch(next).done()

###
@api {GET} /operators List
@apiName List
@apiGroup Operators

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of operator objects
@apiError (Error400) {String} InvalidRequest
###
router.get '/', (req, res, next)->
  Q().then(->
    db.models.Operator
    .find({status: CONST.STATUS.ACTIVE}).deepPopulate(['home_state', 'operating_states'])
  ).then((operators)->
    res.success(operators)
  ).catch(next).done()
###
@api {GET} /operators/:operatorId Get
@apiName Get
@apiGroup Operators

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed operator object
###
router.get '/:operatorId', (req, res, next)->
  res.success(req.operator)

###
@api {POST} /operators Create
@apiName Create
@apiGroup Operators

@apiParam {String} name
@apiParam {String} home_state_id
@apiParam {Array[state.id]} operating_state_ids

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new operator object

###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['name','home_state_id','operating_states'])
      return Q.reject(ERROR.InvalidRequest)
    if not _.isArray(req.body.operating_states)
      return Q.reject(ERROR.InvalidRequest)
    operator = new db.models.Operator({
    name: req.body.name
    home_state: req.body.home_state_id
    operating_states: req.body.operating_states
    })
    operator.save()
  ).then((operator)->
    res.success({id: operator.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /operators/:operatorId Update
@apiName Update
@apiGroup Operators

@apiParam {String} name
@apiParam {String} home_state_id
@apiParam {Array[state.id]} operating_state_ids

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated operator object

###
router.post '/:operatorId', (req, res, next)->
  Q(req.operator).then((operator)->
    _.extend(operator, _.pick(req.body, [
      'name',
    ]))

    if req.body.home_state_id then operator.home_state = req.body.home_state_id
    if req.body.operating_state_ids then operator.operating_states = req.body.operating_state_ids

    operator.save()
  ).then((operator)->
    res.success(operator)
  ).catch(next).done()

###
@api {DELETE} /operators/:operatorId Delete
@apiName Delete
@apiGroup Operators

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:operatorId', (req, res, next)->
  Q(req.operator).then((operator)->
    operator.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router