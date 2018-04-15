rand = require 'randomstring'
express = require 'express'
router = express.Router()

router.param 'tripId', (req, res, next, id)->
  Q().then(->
    db.models.Trip.findOne({_id: id})
  ).then((trip)->
    if not trip
      res.notFound()
    else
      req.trip = trip
      next()
  ).catch(next).done()

###
@api {GET} /trips List
@apiName List
@apiGroup Trips

@apiHeader {String} Authorization Session Token

@apiParam {String} assignment_id
@apiParam {Array} hash array of trip hashes, single hash can be passed as string too
@apiParam {String=started,completed} status

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of trip objects
###
router.get '/',  modules.auth.authenticate(), (req, res, next)->
  Q(req.session.user).then((user)->
    query = {}
    if user.type is CONST.USER_TYPE.CONDUCTOR then query.conductor = user.id
    if req.query.assignment_id then query.assignment = req.query.assignment_id

    if req.query.hash
      if not _.isArray(req.query.hash) then req.query.hash = [req.query.hash]
      query.hash = {'$in': _.uniq(req.query.hash)}

    switch (req.query.status or '').toUpperCase()
      when 'STARTED' then query.status = CONST.TRIP_STATUS.STARTED
      when 'COMPLETED' then query.status = CONST.TRIP_STATUS.COMPLETED

    trips = db.models.Trip.find(query)
    if user.type is 'COMMUTER'
      return trips.deepPopulate(['waybill', 'waybill.vehicle', 'schedule', 'schedule.route',
        'schedule.route.service_type', 'schedule.route.stops', 'schedule.route.stops.stop'])
    else return trips
  ).then((trips)->
    res.success(trips)
  ).catch(next).done()

###
@api {GET} /trips/ongoing Ongoing
@apiName Ongoing
@apiGroup Trips

@apiPermission Conductor
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Ongoing trip object
###
router.get '/ongoing',  modules.auth.authenticate([CONST.USER_TYPE.CONDUCTOR]), (req, res, next)->
  Q(req.session.user).then((user)->
    query = {
      conductor: user.id
      status: CONST.JOURNEY_STATUS.STARTED
    }

    db.models.Trip.findOne(query).select('+secret_key')
  ).then((trip)->
    res.success(trip)
  ).catch(next).done()

###
@api {GET} /trips/:tripId Get
@apiName Get
@apiGroup Trips

@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed trip object
###
router.get '/:tripId', modules.auth.authenticate(), (req, res, next)->
  res.success(req.trip)

###
@api {GET} /trips/:tripId/stats Get
@apiName Get
@apiGroup Trips

@apiPermission Conductor
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed trip object
###
router.get '/:tripId/stats', modules.auth.authenticate([CONST.USER_TYPE.CONDUCTOR]), (req, res, next)->
  Q(req.trip).then((trip)->
    db.models.Journey.aggregate([
      {
        $match: {
          trip: trip.id
        }
      }, {
        $group: {
          _id: '$status'
          count: {$sum: 1}
        }
      }
    ]).exec()
  ).then((journeyStats)->
    stats = {
      journeys: {
        completed: 0
        ongoing: 0
      }
    }
    completedJourneys = _.find(journeyStats, {_id: CONST.JOURNEY_STATUS.COMPLETED})
    if completedJourneys then stats.journeys.completed = completedJourneys.count

    ongoingJourneys = _.find(journeyStats, {_id: CONST.JOURNEY_STATUS.STARTED})
    if ongoingJourneys then stats.journeys.ongoing = ongoingJourneys.count

    res.success(stats)
  ).catch(next).done()

###
@api {POST} /trips Create
@apiName Create
@apiGroup Trips

@apiPermission Conductor
@apiHeader {String} Authorization Session Token

@apiParam {String} assignment_id
@apiParam {String} schedule_id
@apiParam {Float} lat
@apiParam {Float} lon

@apiSuccess {Boolean} status true
@apiSuccess {Object} data new trip object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} OngoingTripFound
@apiError (Error400) {String} AssignmentNotFound
@apiError (Error400) {String} ScheduleNotFound
###
router.post '/', modules.auth.authenticate([CONST.USER_TYPE.CONDUCTOR]), (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['assignment_id', 'schedule_id', 'lat', 'lon'])
      return Q.reject(ERROR.InvalidRequest)
    [
      db.models.Assignment.findOne({_id: req.body.assignment_id, status: CONST.STATUS.ACTIVE})
      db.models.Schedule.findOne({_id: req.body.schedule_id, status: CONST.STATUS.ACTIVE})
      db.models.Trip.find({conductor: req.session.user.id, status: CONST.TRIP_STATUS.STARTED})
    ]
  ).spread((assignment, schedule, ongoing_trip)->
    if not _.isEmpty(ongoing_trip) and not req.query.ignore_ongoing
      return Q.reject(ERROR.OngoingTripFound)

    if not assignment then return Q.reject(ERROR.AssignmentNotFound)
    if not schedule then return Q.reject(ERROR.ScheduleNotFound)

    trip = new db.models.Trip({
      conductor: req.session.user.id
      assignment: assignment
      schedule: schedule
      hash: rand.generate(CONST.HASH_LENGTH)
      secret_key: new Buffer(rand.generate(CONST.SECRET_KEY_LENGTH)).toString(CONST.BASE64)
      start: {
        location: [req.body.lon, req.body.lat]
        datetime: moment()
      }
    })
    trip.save()
  ).then((trip)->
    trip = trip.toJSON();
    trip.assignment = trip.assignment.id;
    res.success(trip, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /trips/:tripId/end End a trip
@apiName EndTrip
@apiGroup Trips

@apiPermission Conductor
@apiHeader {String} Authorization Session Token

@apiParam {Float} lat
@apiParam {Float} lon

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated trip object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} TripAlreadyEnded

###
router.post '/:tripId/end', modules.auth.authenticate([CONST.USER_TYPE.CONDUCTOR]), (req, res, next)->
  trip = req.trip
  Q().then(->
    if not hasRequiredParams(req.body, ['lat', 'lon']) then return Q.reject(ERROR.InvalidRequest)
    if trip.status isnt CONST.TRIP_STATUS.STARTED then return Q.reject(ERROR.TripAlreadyEnded)
    if not req.body.lat or not req.body.lon then
    trip.end = {
      location: [req.body.lon, req.body.lat]
      datetime: moment()
    }
    trip.status = CONST.TRIP_STATUS.COMPLETED
    trip.save()
  ).then((trip)->
    res.success(trip)
  ).catch(next).done()

###
@api {DELETE} /trips/:tripId Delete
@apiName Delete
@apiGroup Trips

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:tripId', modules.auth.authenticate([CONST.USER_TYPE.ADMIN]), (req, res, next)->
  Q(req.trip).then((trip)->
    trip.remove()
  ).then(->
    res.success()
  ).catch(next).done()
   
module.exports = router