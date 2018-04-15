express = require 'express'
router = express.Router()

router.param 'concessionId', (req, res, next, id)->
  Q().then(->
    db.models.Concession.findOne({_id: id})
  ).then((concession)->
    if not concession
      res.notFound()
    else
      req.concession = concession
      next()
  ).catch(next).done()

###
@api {GET} /concessions List
@apiName List
@apiGroup Concessions
@apiParam {String} operator_id
@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of concession objects
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OperatorNotFound
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }
    db.models.Concession.find(query)
  ).then((concessions)->
    res.success(concessions)
  ).catch(next).done()

###
@api {GET} /concessions/:concessionId Get
@apiName Get
@apiGroup Concessions

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed concession object
###
router.get '/:concessionId', (req, res, next)->
  res.success(req.concession)

###
@api {POST} /concessions Create
@apiName Create
@apiGroup Concessions

@apiParam {String} operator_id
@apiParam {String} name
@apiParam {String} code
@apiParam {Number} reduction_value
@apiParam {String=percentage,fixed} reduction_type

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new concession object
###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['operator_id','names', 'code', 'reduction_value','reduction_type'])
      return Q.reject(ERROR.InvalidRequest)
    console.log(req.body)
    db.models.Operator.findOne({
      _id: req.body.operator_id
      status: CONST.STATUS.ACTIVE
    })
  ).then((operator)->
    if not operator then return Q.reject(ERROR.OperatorNotFound)
    concession = new db.models.Concession({
      names: req.body.names
      operator: operator
      code: req.body.code
      reduction_type: req.body.reduction_type
      reduction_value: req.body.reduction_value
    })
    concession.save()
  ).then((concession)->
    res.success({id: concession.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()


###
@api {POST} /concessions/:concessionId Update
@apiName Update
@apiGroup Concessions

@apiParam {String} operator_id
@apiParam {String} name
@apiParam {String} code
@apiParam {Number} reduction_value
@apiParam {String=percentage,fixed} reduction_type

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated concession object
###
router.post '/:concessionId', (req, res, next)->
  Q(req.concession).then((concession)->
    _.extend(concession, _.pick(req.body, [
      'names', 'code', 'reduction_value', 'reduction_type'
    ]))
    concession.save()
  ).then((concession)->
    res.success(concession)
  ).catch(next).done()

###
@api {DELETE} /concessions/:concessionId Delete
@apiName Delete
@apiGroup Concessions

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:concessionId', (req, res, next)->
  Q(req.concession).then((concession)->
    concession.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router