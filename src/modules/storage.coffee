uuid = require 'uuid'
multer = require 'multer'
multerS3 = require 'multer-s3'
S3 = require 'aws-sdk/clients/s3'

s3 = new S3({
  apiVersion: 'latest'
  signatureVersion: 'v4'
  region: config.aws.ses.region
  credentials: {
    accessKeyId: config.aws.access_key_id
    secretAccessKey: config.aws.secret_access_key
  }
})

module.exports = {
  upload : {
    s3: multer({
      storage: multerS3({
        s3: s3
        bucket: config.aws.s3.bucket
        key: (req, file, cb)-> cb(null, uuid.v4())
      })
    }),
    release: multer({
      fileFilter: (req, file, cb)-> cb(null, file.mimetype is 'application/vnd.android.package-archive')
      storage: multerS3({
        s3: s3
        bucket: config.aws.s3.bucket
        acl: 'authenticated-read'
        key: (req, file, cb)-> cb(null, 'releases/' + uuid.v4())
      })
    })
  },
  getUrl: (key, expires=10*60)->
    s3.getSignedUrl('getObject', {
      Bucket: config.aws.s3.bucket
      Key: key
      Expires: expires
    })
}
