emailAddressParser = require 'email-addresses'
express = require 'express'
router = express.Router()

###
@api {POST} /email Send

@apiGroup Email

@apiParam {String} from_address 
@apiParam {String} from_name
@apiParam {String} to_address
@apiParam {String} to_name
@apiParam {String} subject
@apiParam {String} message

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {Object} data.id Id of the newly created notification request
@apiError (Error400) {String} InvalidRequest
###

router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['from_address', 'to_address', 'subject', 'message'])
      return Q.reject(ERROR.InvalidRequest)

    from_address = emailAddressParser.parseOneAddress(req.body.from_address)
    to_address = emailAddressParser.parseOneAddress(req.body.to_address)

    if not from_address or not to_address
      return Q.reject(ERROR.InvalidRequest)
    console.log(req.body)

    from_address.with_name = "#{ req.body.from_name or from_address.name or 'Journee' } <no-reply@#{ config.aws.ses.domain }>"
    to_address.with_name = "#{ req.body.to_name or to_address.name or 'Journee' } <#{ to_address.address }>"

    modules.email.send(from_address.with_name, to_address.with_name, req.body.subject, req.body.message, {
      replyTo: req.body.from_address
    })
  ).then((result)->
    db.models.Notification.log(CONST.NOTIFICATION_TYPE.EMAIL, result.envelope.to.join(","), req, result.messageId)
  ).then((notification)->
    res.success({id: notification.id}, HTTP_STATUS_CODES.ACCEPTED)
  ).catch(next).done()

module.exports = router
