mongoose = require 'mongoose'
rp = require 'request-promise'

after((done)->
  @timeout 0
  console.log 'Clearing the test records...'
  console.log 'Entered  teardown'
  Q.all(_.map(testData.fixtures, (fixture)->
    db.models[fixture.modelName].remove({_id: fixture.data._id})
  )).then(->
    db.disconnect()
  ).then(->
    Q.all(_.map(testData.tokens, (token)->
      rp.post({
        url: apiBaseUrl + '/users/logout'
        json: true
        headers: {
          Authorization: token
        }
      })
    ))
  ).then((res)->
    done()
  ).catch((err)->
     console.log 'Error from teardown'
     console.log err
    ).done()
)