nodemailer = require 'nodemailer'
SES = require 'aws-sdk/clients/ses'

transporter = nodemailer.createTransport({
  SES: new SES({
    apiVersion: '2010-12-01'
    region: config.aws.ses.region or 'eu-west-1'
    credentials: {
      accessKeyId: config.aws.access_key_id
      secretAccessKey: config.aws.secret_access_key
    }
  })
})

module.exports = {
  send: (from, to, subject, message=null, options={})->
    deferred = Q.defer()
    transporter.sendMail(_.extend(options, {
      from: from or "Journee <no-reply@#{ config.aws.ses.domain }>"
      to: to
      subject: subject
      text: message
    }), (err, res)->
      if err then deferred.reject(err)
      else deferred.resolve(res)
    )
    return deferred.promise
}
