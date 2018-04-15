express = require 'express'
router = express.Router()

router.post '/', modules.storage.upload.s3.single('file'), (req, res, next)->
  Q().then(->
    res.success({
      original_name: req.file.originalname
      stored_name: req.file.key
      mime_type: req.file.mimetype
    })
  ).catch(next).done()

module.exports = router