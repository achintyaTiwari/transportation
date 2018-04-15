semver = require 'semver'
express = require 'express'
router = express.Router()

router.param 'releaseId', (req, res, next, id)->
  Q().then(->
    db.models.Release.findOne({_id: id})
  ).then((release)->
    if not release
      res.notFound()
    else
      req.release = release
      next()
  ).catch(next).done()

###
@api {GET} /releases List
@apiName List
@apiGroup Releases

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of release objects
###
router.get '/', (req, res, next)->
  Q().then(->
    query = {
      status: CONST.STATUS.ACTIVE
    }
    db.models.Release.find(query)
  ).then((releases)->
    res.success(releases)
  ).catch(next).done()

###
@api {GET} /releases/:releaseId Get
@apiName Get
@apiGroup Releases

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed release object
###
router.get '/:releaseId', (req, res, next)->
  res.success(req.release)

###
@api {POST} /releases Create
@apiName Create
@apiGroup Releases

@apiParam {String} application_id
@apiParam {String} version
@apiParam {Binary} package

@apiSuccess {Boolean} status true
@apiSuccess {Object} data
@apiSuccess {String} data.id Id of the new release object
###
router.post '/', modules.storage.upload.release.single('package'), (req, res, next)->
  Q().then(->
    if not req.file?.key
      return Q.reject({name: 'InvalidRequest'})
    else if not hasRequiredParams(req.body, ['version', 'application_id'])
      return Q.reject({name: 'InvalidRequest'})
    else if not semver.valid(req.body.version)
      return Q.reject({name: 'InvalidRequest'})

    db.models.Release.findOne({
      application: req.body.application_id
      status: CONST.STATUS.ACTIVE
    })
  ).then((current_release)->
    if current_release and not semver.gt(req.body.version, current_release.version)
      return Q.reject({name: 'InvalidRequest'})

    new_release = new db.models.Release({
      application: req.body.application_id
      version: req.body.version
      path: req.file.key
    })

    if current_release
      current_release.status = CONST.STATUS.INACTIVE
      [new_release.save(), current_release.save()]
    else
      [new_release.save(), null]
  ).spread((current_release, previous_release)->
    modules.push.toTopic(current_release.application, {
      action: "UPDATE_AVAILABLE"
      id: current_release.id
    })
    res.success({id: current_release.id}, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()


###
@api {POST} /releases/:releaseId Update
@apiName Update
@apiGroup Releases

@apiParam {Binary} package

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated release object
###
router.post '/:releaseId', modules.storage.upload.release.single('package'), (req, res, next)->
  Q(req.release).then((release)->
    if req.file?.key then release.path = req.file.key
    release.save()
  ).then((release)->
    res.success(release)
  ).catch(next).done()

###
@api {DELETE} /releases/:releaseId Delete
@apiName Delete
@apiGroup Releases

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:releaseId', (req, res, next)->
  Q(req.release).then((release)->
    release.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router