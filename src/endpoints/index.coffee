glob = require 'glob'
path = require 'path'
express = require 'express'
router = express.Router()

# include all other endpoint definitions
glob '**/*.js', {cwd: __dirname}, (err, files)->
  if err
    console.error 'Unable to load endpoints'
  else
    _.without(files, path.basename(__filename)).forEach (file)->
      parsed_path = path.parse(file)
      base_route = "/#{ parsed_path.name }"
      console.log "Loading endpoints (#{ base_route }) definition: #{ file }"
      router.use base_route, require "#{ __dirname }/#{file}"

if process.env.NODE_ENV isnt 'production'
  router.use '/docs', modules.auth.basic, express.static("#{ __projectdir }/docs")

module.exports = router