util = require 'util'
fs = require 'fs-extra'
winston = require 'winston'
sentry = require 'winston-sentry'
expressWinston = require 'express-winston'

loggers = {}

loggers =
  request: expressWinston.logger({
    transports: [
      new winston.transports.Console()
    ]
    meta: false
    msg: 'HTTP {{res.statusCode}} {{req.method}} {{req.url}} {{res.responseTime}}ms'
  })
  error: expressWinston.errorLogger({
    transports: [
      new winston.transports.Console({json: true, handleExceptions: true})
      new sentry({
        dsn: config.sentry.dsn
        patchGlobal: true
        globalTags: {
          app: "horse"
        }
      })
    ]
  })
  console: new winston.Logger({
    transports: [
      new winston.transports.Console({timestamp: false, showLevel: true})
    ]
  })

if not process.env.DISABLE_LOGGER
  formatArgs = (args) ->
    [ util.format.apply(util.format, Array::slice.call(args)) ]

  console.log = ->
    loggers.console.info.apply loggers.console.info, formatArgs(arguments)

  console.info = ->
    loggers.console.info.apply loggers.console.info, formatArgs(arguments)

  console.warn = ->
    loggers.console.warn.apply loggers.console.warn, formatArgs(arguments)

  console.error = ->
    loggers.console.error.apply loggers.console.error, formatArgs(arguments)

  console.debug = ->
    loggers.console.debug.apply loggers.console.debug, formatArgs(arguments)

module.exports = loggers