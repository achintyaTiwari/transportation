plivoSdk = require 'plivo'

plivo = new plivoSdk.RestAPI({
  authId: config.plivo.auth_id
  authToken: config.plivo.auth_token
})

module.exports = {
  send: (to, message)->
    deferred = Q.defer()
    plivo.send_message({
      src: config.plivo.from_number
      dst: to
      text: message
    }, (status, res)->
      console.log status
      #if err then deferred.reject(err)
      #else deferred.resolve(res)
      deferred.resolve(res)
    )
    return deferred.promise
}