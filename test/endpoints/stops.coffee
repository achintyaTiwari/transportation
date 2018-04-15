describe 'Stops Endpoint {/stops}', ->

  describe 'POST / [Create a new Stop]', ->
    it 'should return bad request for missing params', ->
      api.post('/stops')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create new stop', ->
      api.post('/stops')
      .send testData.stop
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.stop.id = res.body.data.id
     ###
    it 'should return bad request for duplicate name', ->
      api.post('/stops')
      .send testData.stop
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
     ###
  describe 'GET / [List of stops]', ->
    it 'should return success with stops', ->
      api.get('/stops')
      .query ({operator_id:"#{testData.stop.operator_id}"})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.stop.id)

  describe 'GET /:stopId [Get details of particular stop]', ->
    it 'should return properly structured stop object', ->
      api.get("/stops/#{ testData.stop.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.stop.id

    it 'should return not found on invalid stop id', ->
      api.get("/stops/invalid-#{ testData.stop.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:stopId [Update stop details]', ->
    it 'should update only the name and return the updated stop', ->
      testData.stop.name = 'Updated ' + testData.stop.name
      api.post("/stops/#{ testData.stop.id }")
      .send testData.stop
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.name.should.equal testData.stop.name
     ###
    it 'should return bad request for an update results in duplicate name', ->
      api.post("/stops/test-stop")
      .send testData.stop
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
     ###
  describe 'DELETE /:stopId [Delete a stop]', ->
    it 'should return success', ->
      api.del("/stops/#{ testData.stop.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid stop id', ->
      api.del("/stops/#{ testData.stop.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false