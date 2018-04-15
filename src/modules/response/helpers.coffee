# Response Shortcuts
# Response format supported: json

module.exports = (req, res, next)->
  res.sendResponse = (obj)->
    if arguments.length is 2
      if typeof arguments[1] is "number"
        res.statusCode = arguments[1]
      else
        res.statusCode = obj
        obj = arguments[1]

    res.header("Content-Type", "application/json")
    res.send(obj)

  res.success = (data = null, code = HTTP_STATUS_CODES.OK)->
    res.sendResponse(code, {
      status: true
      data: data
    })

  res.badRequest = (code='BAD_REQUEST', message)->
    res.sendResponse(HTTP_STATUS_CODES.BAD_REQUEST, {
      status: false
      error: {
        code: code
        message: message
      }
    })

  res.unAuthorized = (code='UNAUTHORIZED', message='invalid authentication data')->
    res.sendResponse(HTTP_STATUS_CODES.UNAUTHORIZED, {
      status: false
      error: {
        code: code
        message: message
      }
    })

  res.forbidden = (code='FORBIDDEN', message='authentication required')->
    res.sendResponse(HTTP_STATUS_CODES.FORBIDDEN, {
      status: false
      error: {
        code: code
        message: message
      }
    })

  res.notFound = (code='NOT_FOUND', message='requested resource not available')->
    res.sendResponse(HTTP_STATUS_CODES.NOT_FOUND, {
      status: false
      error: {
        code: code
        message: message
      }
    })

  res.serverError = (code='INTERNAL_SERVER_ERROR', message='Internal server error occurred')->
    res.sendResponse(HTTP_STATUS_CODES.INTERNAL_SERVER_ERROR, {
      status: false
      error: {
        code: code
        message: message
      }
    })

  next()