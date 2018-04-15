glob = require 'glob'
path = require 'path'

# All test files inside endpoints directory
files = glob.sync('endpoints/*.coffee', {cwd: __dirname})
_.each(files, (file)-> require path.resolve(__dirname, file))