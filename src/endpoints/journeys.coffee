jwt = require 'jsonwebtoken'
express = require 'express'
router = express.Router()

router.param 'journeyId', (req, res, next, id)->
  Q().then(->
    db.models.Journey.findOne({_id: id})
  ).then((journey)->
    if not journey
      res.notFound()
    else
      req.journey = journey
      next()
  ).catch(next).done()

###
@api {GET} /journeys List
@apiName List
@apiGroup Journeys

@apiHeader {String} Authorization Session Token

@apiParam {String} trip_id
@apiParam {String=started,completed} status

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of journey objects
###
router.get '/',  modules.auth.authenticate(), (req, res, next)->
  Q(req.session.user).then((user)->
    query = {}
    if user.type is CONST.USER_TYPE.COMMUTER then query.commuter = user.id
    if req.query.trip_id then query.trip = req.query.trip_id

    switch (req.query.status or '').toUpperCase()
      when 'STARTED' then query.status = CONST.JOURNEY_STATUS.STARTED
      when 'COMPLETED' then query.status = CONST.JOURNEY_STATUS.COMPLETED

    db.models.Journey.find(query).select('-token')
  ).then((journeys)->
    res.success(journeys)
  ).catch(next).done()

###
@api {GET} /journeys/ongoing Ongoing
@apiName Ongoing
@apiGroup Journeys

@apiPermission Commuter, Conductor
@apiHeader {String} Authorization Session Token

@apiParam {String} commuter_id

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Ongoing journey object
@apiError (Error400) {String} MissingCommuterId
@apiError (Error400) {String} NotAllowed

###
router.get '/ongoing',  modules.auth.authenticate(), (req, res, next)->
  Q(req.session.user).then((user)->
    query = { status: CONST.JOURNEY_STATUS.STARTED }
    if user.type is 'COMMUTER' then query.commuter = user.id
    else if user.type is 'CONDUCTOR'
      if not req.query.commuter_id then return Q.reject(ERROR.MissingCommuterId)
      query.commuter = req.query.commuter_id
    else return Q.reject(ERROR.NotAllowed)

    db.models.Journey.findOne(query)
  ).then((journey)->
    res.success(journey)
  ).catch(next).done()

###
@api {GET} /journeys/:journeyId Get
@apiName Get
@apiGroup Journeys

@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed journey object
###
router.get '/:journeyId', modules.auth.authenticate([CONST.USER_TYPE.COMMUTER]), (req, res, next)->
  res.success(req.journey)

###
@api {POST} /journeys Create
@apiName Create
@apiGroup Journeys

@apiPermission Commuter
@apiHeader {String} Authorization Session Token

@apiParam {String} order_id
@apiParam {String} trip_id
@apiParam {String} stage
@apiParam {String} lat
@apiParam {String} lon

@apiSuccess {Boolean} status true
@apiSuccess {Object} data new journey object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OrderNotFound
@apiError (Error400) {String} OrderNotActive
@apiError (Error400) {String} TripNotFound
###
router.post '/', modules.auth.authenticate(), (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['order_id', 'trip_id', 'stage'])
      return Q.reject(ERROR.InvalidRequest)
    [
      db.models.Order.findOne({_id: req.body.order_id})
      db.models.Trip.findOne({_id: req.body.trip_id, status: CONST.TRIP_STATUS.STARTED}).select('+secret_key')
      db.models.Journey.find({conductor: req.session.user.id, status: CONST.JOURNEY_STATUS.STARTED})
    ]
  ).spread((order, trip, ongoing_journey)->
    if not _.isEmpty(ongoing_journey) and not req.query.ignore_ongoing then return Q.reject(ERROR.OngoingJourneyFound)
    if not order then return Q.reject(ERROR.OrderNotFound)
    else if order.status isnt CONST.ORDER_STATUS.ACTIVE then return Q.reject(ERROR.OrderNotActive)
    # TODO: Validate time bound passes
    if not trip then return Q.reject(ERROR.TripNotFound)

    journey = new db.models.Journey({
      commuter: req.session.user.id
      order: order.id
      trip: trip.id
      start: {
        stage: req.body.stage
        location: [req.body.lon, req.body.lat]
        datetime: moment()
      }
    })

    journey.token = jwt.sign({id: journey.id}, new Buffer(trip.secret_key, CONST.BASE64).toString())

    [order, journey.save()]
  ).spread((order, journey)->
    if order.validity_type is CONST.VALIDITY_TYPE.JOURNEY
      order.validity = order.validity - 1
      if order.validity is 0 then order.status = CONST.ORDER_STATUS.EXPIRED
      order.save()
    res.success(journey, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /journeys/:journeyId/end End a journey
@apiName EndJourney
@apiGroup Journeys

@apiPermission Commuter
@apiHeader {String} Authorization Session Token

@apiParam {Float} lat
@apiParam {Float} lon

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated journey object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} JourneyAlreadyEnded
###
router.post '/:journeyId/end', modules.auth.authenticate(), (req, res, next)->
  journey = req.journey
  Q().then(->
    if not hasRequiredParams(req.body, ['lat', 'lon']) then return Q.reject(ERROR.InvalidRequest)
    if journey.status isnt CONST.JOURNEY_STATUS.STARTED then return Q.reject(ERROR.JourneyAlreadyEnded)
    if not req.body.lat or not req.body.lon then
    journey.end = {
      stage: req.body.stage
      location: [req.body.lon, req.body.lat]
      datetime: moment()
    }
    journey.status = CONST.JOURNEY_STATUS.COMPLETED
    journey.save()
  ).then((journey)->
    res.success(journey)
  ).catch(next).done()

###
@api {DELETE} /journeys/:journeyId Delete
@apiName Delete
@apiGroup Journeys

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:journeyId', modules.auth.authenticate([CONST.USER_TYPE.ADMIN]), (req, res, next)->
  Q(req.journey).then((journey)->
    journey.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router