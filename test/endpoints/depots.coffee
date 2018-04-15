describe  'Depots Endpoint {/depots}', ->

  describe 'POST / [Create a new depot]', ->
    it 'should return bad request for missing params', ->
      api.post('/depots')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      testData.depot.operator_id = ''
      api.post('/depots')
      .send testData.depot
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create new depot', ->
      testData.depot.operator_id = 'test-operator'
      api.post('/depots')
      .send testData.depot
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.depot.id = res.body.data.id
    ###
    it 'should return bad request for duplicate name', ->
      #testData.depot.name = ''      
      testData.depot.operator_id = 'test-operator'
      api.post('/depots')
      .send testData.depot
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###
  describe 'GET / [List of depots]', ->
    it 'should return success with depots', ->
      api.get("/depots?operator_id=#{testData.depot.operator_id}")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.depot.id)

  describe 'GET /:depotId [Get details of particular depot]', ->
    it 'should return the correct depot', ->
      api.get("/depots/#{ testData.depot.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.depot.id

    it 'should return not found on invalid depot id', ->
      api.get("/depots/invalid-#{ testData.depot.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      #.expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:depotId [Update depot details]', ->
    it 'should update only the name and return the updated depot', ->
      testData.depot.name = 'Updated ' + testData.depot.name
      api.post("/depots/#{ testData.depot.id }")
      .send testData.depot
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.name.should.equal testData.depot.name
    ###
    it 'should return bad request for an update results in duplicate name', ->
      api.post("/depots/test-depot")
      .send testData.depot
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###
  describe 'DELETE /:depotId [Delete a depot]', ->
    it 'should return success', ->
      api.del("/depots/#{ testData.depot.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
 
    it 'should return not found on invalid depot id', ->
      api.del("/depots/invalid-#{ testData.depot.id }")
      .set('Authorization', testData.tokens.admin)
      #.expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
