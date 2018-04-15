jwt = require 'jsonwebtoken'
passcode = require 'passcode'
basicAuth = require 'basic-auth'

module.exports = {
  authenticate: (roles)->
    expected_roles = if _.isArray(roles) then roles else arguments
    (req, res, next)->
      session_token = null
      Q().then(->
        if req.headers.authorization
          session_token = req.headers.authorization
        else if req.query and req.query.token
          session_token = req.query.token
        else if req.body and req.body.token
          session_token = req.body.token
        if not session_token then return Q.reject(ERROR.SessionTokenNotFound)
        #else return Q.nfcall(jwt.verify, session_token, config.session.secret)
        else return Q.resolve(jwt.decode(session_token))
      ).then((decoded_token)->
        if not decoded_token or not decoded_token.user_id then return Q.reject(ERROR.SessionTokenInvalid)
        db.models.Session.findOne({
          user: decoded_token.user_id
          status: CONST.STATUS.ACTIVE
        }).populate('user').exec()
      ).then((session)->
        if session?.token isnt session_token then return Q.reject(ERROR.SessionTokenInvalid)
        req.session = session
        if not _.some(expected_roles) then return next()
        else if _.includes(expected_roles, session.user.type) then return next()
        else return Q.reject(ERROR.UserNotAuthorized)
      ).catch(next).done()

  getSessionToken: (user)->
    token = jwt.sign({user_id: user.id}, config.session.secret)
    return Q.resolve( token)

  basic: (req, res, next)->
    unauthorized = (res)->
      res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
      res.send HTTP_STATUS_CODES.UNAUTHORIZED

    user = basicAuth(req)
    if !user or !user.name or !user.pass
      return unauthorized(res)
    if user.name is config.api_doc.username and user.pass is config.api_doc.password
      next()
    else
      unauthorized(res)
}
