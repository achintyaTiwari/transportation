validator = require 'validator'
express = require 'express'
router = express.Router()

router.param 'userId', (req, res, next, id)->
  Q().then(->
    db.models.User.findOne({_id: id, status: {'$ne': CONST.STATUS.INACTIVE}})
  ).then((user)->
    if not user
      res.notFound()
    else
      req.user = user
      next()
  ).catch(next).done()

###
@api {GET} /users List
@apiName List
@apiGroup Users

@apiParam {String} status
@apiParam {String=operator_admin,depot_admin,conductor,driver,commuter} type

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of user objects
###
# TODO: implement pagination and filter
router.get '/', (req, res, next)->
  Q().then(->
    where = {}
    status = (req.query.status or 'active').toUpperCase()
    switch status
      when 'ACTIVE' then where.status = CONST.STATUS.ACTIVE
    if req.query.type then where.type = req.query.type
    db.models.User.find(where)
  ).then((users)->
    res.success(users)
  ).catch(next).done()

###
@api {GET} /users/me Profile
@apiName Profile
@apiGroup Users

@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {Object} user Details for the currently authenticated User
###
router.get '/me', modules.auth.authenticate(), (req, res, next)->
  Q(req.session.user).then((user)->
    if user.type is 'CONDUCTOR'
      [user,
      db.models.Assignment.findOne({
        conductor: user.id
        status: CONST.STATUS.ACTIVE
      })]
    else if user.type is 'COMMUTER'
      [user,
       db.models.Order.find({
         user: user.id
         status: CONST.ORDER_STATUS.ACTIVE
       })]
    else
      [user]
  ).spread((user, extra)->
    userObj = user.toJSON()
    if user.type is 'CONDUCTOR' then userObj.waybill = extra
    else if user.type is 'COMMUTER' then userObj.orders = extra
    console.log userObj
    res.success(userObj)
  ).catch(next).done()

###
@api {GET} /users/otp OTP Request
@apiName OTP
@apiGroup Users

@apiParam {String} mobile_number
@apiParam {String=commuter,conductor} [type=conductor]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.user_id  Id of user whose otp has been generated. This id is mandatory to validate the OTP
@apiError (Error400) {String} MissingUserType
@apiError (Error400) {String} UserNotFound
###
router.get '/otp', (req, res, next)->
  Q((req.query.type or 'conductor').toLowerCase()).then((user_type)->
    if not _.includes(['conductor', 'commuter'], user_type)
      return Q.reject(ERROR.MissingUserType)

    switch user_type
      when 'conductor' then user_type = CONST.USER_TYPE.CONDUCTOR
      when 'commuter' then user_type = CONST.USER_TYPE.COMMUTER

    db.models.User.findOne({
      mobile_number: parseInt(req.query.mobile_number)
      type: user_type
      status: CONST.STATUS.ACTIVE
    })
  ).then((user)->
    if not user then Q.reject(ERROR.UserNotFound)
    else [user, modules.auth.otp.generate(user)]
  ).spread((user, code)->
    user.otp = code
    user.save()
  ).then((user)->
    res.success({user_id: user.id})
  ).catch(next).done()

###
@api {POST} /users/login Login
@apiName Login
@apiGroup Users

@apiParam {String=admin,commuter,conductor} [type=conductor]

@apiParam (Login with Username) {String} username Email address / Mobile number of the user
@apiParam (Login with Username) {String} password Password entered by user

@apiParam (Login with OTP) {String} user_id The id returned while generating OTP
@apiParam (Login with OTP) {String} otp OTP entered by user

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.session_token Session Token for authenticated API calls
@apiSuccess {Object} data.preferences=null Users last recorded preferences
@apiError (Error400) {String} MissingUserType
@apiError (Error400) {String} MissingParams
@apiError (Error400) {String} MissingOTP
@apiError (Error400) {String} InvalidUsernameFormat
@apiError (Error400) {String} UserNotFound
@apiError (Error400) {String} InvalidCredential
###
router.post '/login', (req, res, next)->
  Q((req.body.type or 'ANONYMOUS').toLowerCase()).then((user_type)->
    if not _.includes(['admin', 'conductor', 'commuter'], user_type)
      return Q.reject(ERROR.MissingUserType)

    if not req.body.username and not req.body.user_id
      return Q.reject(ERROR.MissingParams)
    else if req.body.username and not req.body.password
      return Q.reject(ERROR.MissingPassword)
    else if req.body.user_id and not req.body.otp
      return Q.reject(ERROR.MissingOTP)

    where = {
      type: user_type.toUpperCase()
      status: CONST.STATUS.ACTIVE
    }

    if req.body.username
      if validator.isEmail(req.body.username)
        where.email_address = req.body.username
      else if req.body.username.length is 10 and validator.isInt(req.body.username)
        where.mobile_number = req.body.username
      else
        return Q.reject(ERROR.InvalidUsernameFormat)
    else
      where._id = req.body.user_id

    db.models.User.findOne(where)
  ).then((user)->
    if not user then return Q.reject(ERROR.UserNotFound)
    if req.body.password
      [user, user.verifyPassword(req.body.password)]
    else
      [user, modules.auth.otp.verify(user, req.body.otp)]
  ).spread((user, valid_credentials)->
    if not valid_credentials then return Q.reject(ERROR.InvalidCredential)
    [user, db.models.Session.findOne({user: user.id, status: CONST.STATUS.ACTIVE})]
  ).spread((user, existing_session)->
    if existing_session then Q.resolve([user, existing_session, existing_session.token])
    else [user, null, modules.auth.getSessionToken(user)]
  ).spread((user, existing_session, token)->
    if existing_session
      [user, user.preferences, existing_session]
    else
      session = db.models.Session({
        token: token
        user: user.id
      })
      [user, user.preferences, session.save()]
  ).spread((user, prefs, session)->
    res.success({
      session_token: session.token
      preferences: prefs
      profile: user
    })
  ).catch(next).done()

###
@api {POST} /users/logout Logout
@apiName Logout
@apiGroup Users

@apiHeader {String} Authorization Session Token

@apiParam {Object} [preferences]
  User preference to persist in the database, the same object will be returned when the user login next time

@apiSuccess {Boolean} status true
###
router.post '/logout', modules.auth.authenticate(), (req, res, next)->
  Q(req.session).then((session)->
    session.status = CONST.STATUS.INACTIVE
    if not req.body.preferences then return session.save()
    user = session.user
    user.preferences = req.body.preferences
    [user.save(), session.save()]
  ).then(->
    res.success()
  ).catch(next).done()

###
@api {POST} /users Create
@apiName Create
@apiGroup Users

@apiParam {String} operator_id
@apiParam {String} [first_name]
@apiParam {String} [last_name]
@apiParam {String} email_address
@apiParam {String} mobile_number
@apiParam {Array} [alt_mobile_numbers]
@apiParam {String} [password]
@apiParam {String} [pin=123456]
@apiParam {Object} [preferences]
@apiParam {String=operator_admin,depot_admin,conductor,driver,commuter} type

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the successfully created user
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} MongoError
###
router.post '/', (req, res, next)->
  Q().then(->
    if not req.body.mobile_number or not req.body.type
      return Q.reject(ERROR.InvalidRequest)
    user = new db.models.User({
      operator: req.body.operator_id
      first_name: req.body.first_name
      last_name: req.body.last_name
      email_address: req.body.email_address
      mobile_number: req.body.mobile_number
      alt_mobile_numbers: req.body.alt_mobile_numbers
      password: req.body.password
      pin: req.body.pin
      preferences: req.body.preferences
      type: req.body.type
    })
    return user.save()
  ).then((user)->
    res.success({id: user.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {GET} /users/:userId Get
@apiName Get
@apiGroup Users

@apiSuccess {Boolean} status true
@apiSuccess {Object} data User object
###
router.get '/:userId', (req, res, next)->
  res.success(req.user)

###
@api {POST} /users/:userId Update
@apiName Update
@apiGroup Users

@apiParam {String} [first_name]
@apiParam {String} [last_name]
@apiParam {String} [email_address]
@apiParam {String} [mobile_number]
@apiParam {Array} [alt_mobile_numbers]
@apiParam {String} [password]
@apiParam {String} [pin]
@apiParam {Object} [preferences]
@apiParam {String} [status]

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated User Object will be returned
###
router.post '/:userId', (req, res, next)->
  Q(req.user).then((user)->
    if req.body.first_name then user.first_name = req.body.first_name
    if req.body.last_name then user.last_name = req.body.last_name
    if req.body.email_address then user.email_address = req.body.email_address
    if req.body.mobile_number then user.mobile_number = req.body.mobile_number
    if req.body.alt_mobile_numbers then user.alt_mobile_numbers = req.body.alt_mobile_numbers
    if req.body.password then user.password = req.body.password
    if req.body.pin then user.pin = req.body.pin
    if req.body.preferences then user.preferences = _.extend(user.preferences, req.body.preferences)
    if req.body.status then user.status = req.body.status
    user.save()
  ).then((user)->
    res.success(user)
  ).catch(next).done()

###
@api {DELETE} /users/:userId Delete
@apiName Delete
@apiGroup Users

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:userId', (req, res, next)->
  Q(req.user).then((user)->
    user.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router
