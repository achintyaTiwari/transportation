module.exports = {
  auth          : require './auth'
  push          : require './push'
  email         : require './email'
  sms           : require './sms'
  storage       : require './storage'
  errors        : require './errors'
  middlewares   :
    response      :
      helpers       : require './response/helpers'
      errorHandler  : require './response/errorHandler'
    logger        : require './logger'
    cors          : require './cors'
}