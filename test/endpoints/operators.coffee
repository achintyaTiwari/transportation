describe 'Operators Endpoint {/operators}', ->

  describe 'POST / [Create a new operator]', ->
    
    it 'should return bad request for missing params', ->
      api.post('/operators')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
  
    it 'should create a new operator', ->
      api.post('/operators')
      .send testData.operator
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.operator.id = res.body.data.id
    ###
    it 'should return bad request for duplicate name', ->
      api.post('/operators')
      .send testData.operator
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###
  describe 'GET / [List of operators]', ->
    it 'should return success with operators', ->
      api.get('/operators')
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.operator.id)

  describe 'GET /:operatorId [Get details of particular operator]', ->
    it 'should return the correct operator', ->
      api.get("/operators/#{ testData.operator.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.operator.id

    it 'should return not found on invalid operator id', ->
      api.get("/operators/invalid-#{ testData.operator.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:operatorId [Update operator details]', ->
    it 'should update only the name and return the updated operator', ->
      testData.operator.name = 'Updated ' + testData.operator.name
      api.post("/operators/#{ testData.operator.id }")
      .send testData.operator
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.name.should.equal testData.operator.name
    ###
    it 'should return bad request for an update results in duplicate name', ->
      testData.operator.name = 'Demo Transport Operator'
      api.post("/operators/#{ testData.operator.id }")
      .send testData.operator
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###     
  describe 'DELETE /:operatorId [Delete a operator]', ->
    it 'should return success', ->
      api.del("/operators/#{ testData.operator.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid operator id', ->
      api.del("/operators/#{ testData.operator.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false