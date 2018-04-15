express = require 'express'
router = express.Router()

###
@api {GET} /statics/states List
@apiName List
@apiGroup States

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of state objects
###
router.get '/states', (req, res, next)->
  Q().then(->
    db.models.State.find()
  ).then((states)->
    res.success(states)
  ).catch(next).done()

module.exports = router