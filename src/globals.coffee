

path = require 'path'

global.HTTP_STATUS_CODES = require 'http-status-codes'

global._ = require 'lodash'

global.Q = require 'q'

global.moment = require 'moment'

global.__projectdir = "#{ __dirname }#{ path.sep }"

global.__rootdir = "#{ process.cwd() }#{ path.sep }"

global.fullPath = (file)-> "#{ __projectdir }#{ file }"

global.include = (file)-> require "#{ fullPath(file) }"

global.hasRequiredParams = (obj, required_keys)-> _.every(required_keys, _.partial(_.has, obj))

global.CONST = {
  BASE64: 'base64'
  HASH_LENGTH: 8
  SECRET_KEY_LENGTH: 32
  STATUS: {
    ACTIVE: 1
    INACTIVE: 2
  }
  VALIDITY_TYPE: {
    DAY: 1
    JOURNEY: 2
    CALENDER_MONTH: 3
  }
  USER_TYPE: {
    ADMIN: 1
    CONDUCTOR: 2
    COMMUTER: 3
    DRIVER: 4
  }
  ORDER_TYPE: {
    PASS: 1
    SINGLE_TICKET: 2
  }
  ORDER_STATUS: {
    CREATED: 1
    PAYMENT_APPROVED: 2
    PAYMENT_FAILED: 3
    ACTIVE: 4
    EXPIRED: 5
    CANCELLED: 6
  }
  TRIP_STATUS: {
    STARTED: 1
    COMPLETED: 2
  }
  JOURNEY_STATUS: {
    STARTED: 1
    COMPLETED: 2
  }
  NOTIFICATION_TYPE: {
    PUSH: 1
    EMAIL: 2
    SMS: 3
  }
  SCHEDULE_DIRECTION: {
    UP: 0
    DOWN: 1
  }
  PAYMENT_METHOD: {
    CASH: 'CASH'
    BANK_CARD: 'BANK_CARD'
    SMART_CARD: 'SMART_CARD'
    UPI: 'UPI'
    WALLET: 'WALLET'
  }
}

###
Environment Specific Configuration
==================================
Development : ./config/development.json
Staging     : ./config/staging.json
Production  : ./config/production.json
All the configuration files are git ignored, when ever you do configuration change, please update in template.json
###
global.config = require "#{ __rootdir }config/#{ process.env.NODE_ENV || 'development' }"

global.db = include 'models'

global.modules = include 'modules'

global.rand = require 'randomstring'

global.ERROR = modules.errors
