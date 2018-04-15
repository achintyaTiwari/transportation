describe 'Trips Endpoint {/trips}', ->

  describe 'POST / [Create a new trip]', ->
    #pass
    it 'should return unauthorized for missing session token', ->
      api.post('/trips')
      .expect HTTP_STATUS_CODES.UNAUTHORIZED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
     #pass
    it 'should return forbidden if the user is not authorized to start a trip', ->
      api.post('/trips')
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.FORBIDDEN
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for missing params', ->
      api.post('/trips')
       .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for invalid assignment', ->
      api.post('/trips')
      .set('Authorization', testData.tokens.conductor)
      .send testData.trip
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for invalid schedule', ->
      testData.trip.assignment_id = 'test-assignment'
      api.post('/trips')
      .set('Authorization', testData.tokens.conductor)
      .send testData.trip
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create a new trip', ->
      testData.trip.schedule_id = 'test-schedule'
      # We have created trip with test-trip already for testing
      # so, without 'ignore_ongoing' this test case will fail
      api.post('/trips?ignore_ongoing=true')
      .set('Authorization', testData.tokens.conductor)
      .send testData.trip
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        _.extend(testData.trip, res.body.data)
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('id')
        res.body.data.should.have.property('hash').and.that.is.of.length CONST.HASH_LENGTH
        res.body.data.should.have.property('secret_key')
        new Buffer(res.body.data.secret_key, CONST.BASE64).toString().should.be.of.length CONST.SECRET_KEY_LENGTH

    it 'should return bad request for duplicate ongoing trip', ->
      api.post('/trips')
      .set('Authorization', testData.tokens.conductor)
      .send testData.trip
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'GET / [List of trips]', ->
    it 'should return success with trips', ->
      api.get('/trips')
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.trip.id)
        res.body.data.should.all.not.have.property 'secret_key'

    it 'should return success with trips and also return secret key when conductor requesting', ->
      api.get('/trips')
      .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.trip.id)
        res.body.data.should.all.not.have.property 'secret_key'

    it 'should be possible to search by single hash', ->
      api.get('/trips')
      .query({hash: testData.trip.hash})
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array').and.of.length 1
        res.body.data.should.contain.an.item.with.property('id', testData.trip.id)
        res.body.data.should.all.not.have.property 'secret_key'

    it 'should be possible to search by multiple hashes', ->
      api.get('/trips')
      .query({hash: [testData.trip.hash, 'test-trip-hash']})
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array').and.of.length 2
        res.body.data.should.contain.an.item.with.property('id', testData.trip.id)
        res.body.data.should.contain.an.item.with.property('id', 'test-trip')
        res.body.data.should.all.not.have.property 'secret_key'

  describe 'GET /ongoing [Get ongoing trip]', ->
    it 'should return the currently ongoing trip', ->
      api.get('/trips/ongoing')
      .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('secret_key')

  describe 'GET /:tripId [Get details of particular trip]', ->
    it 'should return the correct trip', ->
      api.get("/trips/#{ testData.trip.id }")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.trip.id

    it 'should return not found on invalid trip id', ->
      api.get("/trips/invalid-#{ testData.trip.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:tripId/end [End trip]', ->
    it 'should return unauthorized for missing session token', ->
      api.post("/trips/#{ testData.trip.id }/end")
      .expect HTTP_STATUS_CODES.UNAUTHORIZED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return forbidden if the user is not authorized to end a trip', ->
      api.post("/trips/#{ testData.trip.id }/end")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.FORBIDDEN
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request for missing params', ->
      api.post("/trips/#{ testData.trip.id }/end")
      .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return success after marking the trip as complete', ->
      api.post("/trips/#{ testData.trip.id }/end")
      .set('Authorization', testData.tokens.conductor)
      .send testData.trip
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('id').and.equal testData.trip.id
        res.body.data.should.have.property('status').and.equal 'COMPLETED'

  describe 'DELETE /:tripId [Delete a trip]', ->
    it 'should return success', ->
      api.del("/trips/#{ testData.trip.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid trip id', ->
      api.del("/trips/#{ testData.trip.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false