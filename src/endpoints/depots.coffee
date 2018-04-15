express = require 'express'
router = express.Router()

router.param 'depotId', (req, res, next, id)->
  Q().then(->
    db.models.Depot.findOne({_id: id})
  ).then((depot)->
    if not depot then return res.notFound()
    else
    req.depot = depot
    next()
  ).catch(next).done()

###
@api {GET} /depots List
@apiName List
@apiGroup Depots

@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of depot objects
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OperatorNotFound
@apiError (Error400) {String} MongoError
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.RequiredParamsMissing)

    query = {
      operator: req.query.operator_id
      status: CONST.STATUS.ACTIVE
    }
    db.models.Depot.find(query)
  ).then((depots)->
    res.success(depots)
  ).catch(next).done()
###
@api {GET} /depots/:depotId Get
@apiName Get
@apiGroup Depots

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed depot object
###
router.get '/:depotId', (req, res, next)->
  #res.success(req.depot)
  Q().then(->
    db.models.Depot.findOne({_id:req.params.depotId})
    ).then((depots)->
      console.log(depots)
      res.success(depots)
    ).catch(next).done()

###
@api {POST} /depots Create
@apiName Create
@apiGroup Depots

@apiParam {String} name
@apiParam {String} operator_id

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new depot object
###
router.post '/', (req, res, next)->
  Q().then(->
    if not req.body.name then return Q.reject(ERROR.RequiredParamsMissing)
    db.models.Operator.findOne({
      _id: req.body.operator_id
      status: CONST.STATUS.ACTIVE
    })
  ).then((operator)->
    if not operator then return Q.reject(ERROR.InvalidOperatorId)
    depot = new db.models.Depot({
      name: req.body.name
      operator: operator
    })
    depot.save()
  ).then((depot)->
    res.success({id: depot.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()


###
@api {POST} /depots/:depotId Update
@apiName Update
@apiGroup Depots

@apiParam {String} name
@apiParam {String} from
@apiParam {String} to

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated depot object
###
router.post '/:depotId', (req, res, next)->
  Q(req.depot).then((depot)->
    _.extend(depot, _.pick(req.body, [
      'name'
    ]))
    depot.save()
  ).then((depot)->
    res.success(depot)
  ).catch(next).done()

###
@api {DELETE} /depots/:depotId Delete
@apiName Delete
@apiGroup Depots

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:depotId', (req, res, next)->
  Q(req.depot).then((depot)->
    depot.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router