describe 'Concessions Endpoint {/concessions}', ->

  sampleConcession =
    operator_id: 'invalid-operator'
    names: "Sample Concession"
    code: '50OFF'
    reduction_value: 50
    reduction_type: 'percentage'

  describe 'POST / [Create a new concession]', ->
    it 'should return bad request for missing params', ->
      api.post('/concessions')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      api.post('/concessions')
        .send sampleConcession
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should create new concession', ->
      sampleConcession.operator_id = 'test-operator'
      api.post('/concessions')
        .send sampleConcession
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.should.have.property 'id'
          sampleConcession.id = res.body.data.id
    ###
    it 'should return bad request for duplicate name', ->
      api.post('/concessions')
        .send sampleConcession
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
   ###
  describe 'GET / [List of concessions]', ->
    it 'should return bad request on missing operator id', ->
      api.get('/concessions')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return success with concessions', ->
      api.get('/concessions')
        .query {operator_id: sampleConcession.operator_id}
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('array')
          res.body.data.should.contain.an.item.with.property('id', sampleConcession.id)

  describe 'GET /:concessionId [Get details of particular concession]', ->
    it 'should return the correct depot', ->
      api.get("/concessions/#{ sampleConcession.id }")
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.id.should.equal sampleConcession.id

    it 'should return not found on invalid concession id', ->
      api.get("/concessions/invalid-#{ sampleConcession.id }")
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
  
  describe 'POST /:concessionId [Update concession details]', ->
    it 'should update only the reduction value and return the updated concession', ->
      sampleConcession.reduction_value = 52.5
      api.post("/concessions/#{ sampleConcession.id }")
        .send sampleConcession
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.reduction_value.should.equal sampleConcession.reduction_value
    ###
    it 'should return bad request for an update results in duplicate object', ->
      api.post("/concessions/test-concession")
        .send sampleConcession
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
    ###
  describe 'DELETE /:concessionId [Delete a concession]', ->
    it 'should return success', ->
      api.del("/concessions/#{ sampleConcession.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid concession id', ->
      api.del("/concessions/#{ sampleConcession.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false