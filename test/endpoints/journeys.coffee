describe 'Journeys Endpoint {/journeys}', ->

  describe 'POST / [Create a new journey]', ->
    it 'should return unauthorized for missing session token', ->
      api.post('/journeys')
      .expect HTTP_STATUS_CODES.UNAUTHORIZED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return forbidden if the user is not authorized to start a journey', ->
      api.post('/journeys')
      .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.FORBIDDEN
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for missing params', ->
      api.post('/journeys')
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for invalid order', ->
      api.post('/journeys')
      .set('Authorization', testData.tokens.commuter)
      .send testData.journey
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for invalid trip', ->
      testData.journey.order_id = 'test-order'
      api.post('/journeys')
      .set('Authorization', testData.tokens.commuter)
      .send testData.journey
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create new journey', ->
      testData.journey.trip_id = 'test-trip'
      # We have created journey with test-journey already for testing, so without 'ignore_ongoing' this test case will fail
      api.post('/journeys?ignore_ongoing=true')
      .set('Authorization', testData.tokens.commuter)
      .send testData.journey
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property 'id'
        res.body.data.should.have.property 'token'
        testData.journey.id = res.body.data.id
        secret_key = new Buffer(testData.fixtures.trip.data.secret_key, CONST.BASE64).toString()
        require('jsonwebtoken').verify(res.body.data.token, secret_key, (err, decoded)->
          if err then return done(err)
          decoded.should.have.property('id')
          require("validator").isUUID(decoded.id, 4).should.be.true
          done()
        )

    it 'should return bad request for duplicate ongoing journey', ->
      api.post('/journeys')
      .set('Authorization', testData.tokens.commuter)
      .send testData.journey
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'GET / [List of journeys]', ->
    it 'should return success with journeys', ->
      api.get('/journeys')
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.journey.id)

  describe 'GET /ongoing [Get ongoing journey]', ->
    it 'should return the currently ongoing journey', ->
      api.get('/journeys/ongoing')
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('token')

  describe 'GET /:journeyId [Get details of particular journey]', ->
    it 'should return the correct journey', ->
      api.get("/journeys/#{ testData.journey.id }")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.journey.id

    it 'should return not found on invalid journey id', ->
      api.get("/journeys/invalid-#{ testData.journey.id }")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:journeyId/end [End journey]', ->
    it 'should return unauthorized for missing session token', ->
      api.post("/journeys/#{ testData.journey.id }/end")
      .expect HTTP_STATUS_CODES.UNAUTHORIZED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return forbidden if the user is not authorized to end a journey', ->
      api.post("/journeys/#{ testData.journey.id }/end")
      .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.FORBIDDEN
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for missing params', ->
      api.post("/journeys/#{ testData.journey.id }/end")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return success after marking the journey as complete', ->
      api.post("/journeys/#{ testData.journey.id }/end")
      .set('Authorization', testData.tokens.commuter)
      .send testData.journey
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('id').and.equal testData.journey.id
        res.body.data.should.have.property('status').and.equal 'COMPLETED'

  describe 'DELETE /:journeyId [Delete a journey]', ->
    it 'should return success', ->
      api.del("/journeys/#{ testData.journey.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid journey id', ->
      api.del("/journeys/#{ testData.journey.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false