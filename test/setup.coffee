mongoose = require 'mongoose'
rp = require 'request-promise'

before((done)->
  @timeout 0
  console.log 'Setting up the test records...'
  console.log 'Entering setup...'
  db.connect(false).then(->
    Q.all(_.map(testData.fixtures, (fixture)->
      db.models[fixture.modelName].create(fixture.data)
    ))
  ).then(->
    rp.post({
      url: apiBaseUrl + '/users/login'
      json: true
      form: {
        username: testData.fixtures.admin.data.email_address
        password: testData.fixtures.admin.data.password
        type: 'admin'
      }
    })
  ).then((res)->
    testData.tokens.admin = res.data.session_token
    rp.post({
      url: apiBaseUrl + '/users/login'
      json: true
      form: {
        username: testData.fixtures.commuter.data.mobile_number
        password: testData.fixtures.commuter.data.password
        type: 'commuter'
      }
    })
  ).then((res)->
    testData.tokens.commuter = res.data.session_token
    rp.post({
      url: apiBaseUrl + '/users/login'
      json: true
      form: {
        username: testData.fixtures.conductor.data.mobile_number
        password: testData.fixtures.conductor.data.password
        type: 'conductor'
      }
    })
  ).then((res)->
    testData.tokens.conductor = res.data.session_token
    console.log("Let me do stuff")
    done()
  ).catch((err)->
    console.log('Exiting setup with errors')
    console.log(err)
    ).done()
)