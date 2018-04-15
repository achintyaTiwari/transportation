fs = require('fs')

module.exports = (grunt) ->

  for key of grunt.file.readJSON('package.json').devDependencies
    if key isnt 'grunt' and key.indexOf('grunt') is 0
      grunt.loadNpmTasks key

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    env:
      dev:
        NODE_ENV : 'development'
      mocha:
        DISABLE_LOGGER : true

    coffee:
      options:
        bare: true
        sourceMap: true
      src:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*.coffee']
          dest: 'app/'
          ext: '.js'
        ]

    watch:
      copy:
        files: ['src/**/*']
        tasks: ['build:app']
        options:
          spawn: false
          event: ['added', 'changed']
      remove:
        files: ['src/**/*']
        tasks: ['clean', 'build:app']
        options:
          spawn: false
          event: ['deleted']

    clean:
      app: ['app']

    nodemon:
      app:
        script: 'app/server.js'
        options:
          ignore: ['node_modules/**', 'test/**'],
          ext: 'js,coffee'
          nodeArgs: ['--inspect']
          delay: 1000

    concurrent:
      dev:
        tasks: ['watch', 'nodemon:app']
        options:
          logConcurrentOutput: true

    mochaTest:
      test:
        src: [
          'test/setup.coffee'
          'test/' + (grunt.option('file') or 'all').replace(".", "/") + '.coffee'
          'test/teardown.coffee'
        ]
        options:
          require: [
            'coffee-script/register'
            'test/init.coffee'
          ]
          timeout: 5000
          clearRequireCache: true

    apidoc:
      api:
        src: 'src/'
        dest: 'docs/'

  grunt.registerTask 'default', [
    'build'
    'doc:generate'
  ]

  grunt.registerTask 'build', [
    'build:app'
  ]

  grunt.registerTask 'build:app', [
    'coffee:src'
  ]

  grunt.registerTask 'doc:generate', [
    'apidoc:api'
  ]

  grunt.registerTask 'dev', [
    'env:dev'
    'build:app'
    'concurrent:dev'
  ]

  grunt.registerTask 'test', [
    'env:dev'
    'env:mocha'
    'mochaTest:test'
  ]