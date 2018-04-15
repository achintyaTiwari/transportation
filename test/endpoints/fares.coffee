describe 'Fares Endpoint {/fares}', ->

  sampleFare =
    operator_id: 'test-operator'
    name: 'City Deluxe'
    code: 'FCD'
    slabs: [{
      name: '0-25'
      value: 1.25
    }, {
      name: '26-50'
      value: 3.00
    }]
    type: 'luggage'

  describe 'POST / [Create a new fare]', ->
    it 'should return bad request on invalid params', ->
      api.post('/fares')
      .send _.omit(sampleFare, ['name', 'operator_id', 'type'])
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create a new fare', ->
      api.post('/fares')
      .send sampleFare
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        sampleFare.id = res.body.data.id
     ###
    it 'should return bad request for duplicate code', ->
      api.post('/fares')
      .send sampleFare
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###
  describe 'GET / [List of fares]', ->
    it 'should return bad request on missing operator id', ->
      api.get('/fares')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return success with list of fares', ->
      api.get('/fares')
      .query {operator_id: sampleFare.operator_id}
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', sampleFare.id)

  describe 'GET /:fareId [Get details of particular fare]', ->
    it 'should return a proper fare object', ->
      api.get("/fares/#{ sampleFare.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal sampleFare.id

    it 'should return not found on invalid fare id', ->
      api.get("/fares/invalid-#{ sampleFare.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:fareId [Update fare details]', ->
    it 'should update only the name and return the updated fare', ->
      sampleFare.name = 'City Ordinary'
      api.post("/fares/#{ sampleFare.id }")
      .send sampleFare
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.name.should.equal sampleFare.name

    it 'should add a slab and return the updated fare', ->
      sampleFare.slabs.push({
        name: '51-75', value: 5.00
      })
      api.post("/fares/#{ sampleFare.id }")
        .send sampleFare
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.slabs.should.have.lengthOf sampleFare.slabs.length
          res.body.data.slabs.should.contain.an.item.with.property('name', '51-75')
    ###
    it 'should return bad request for an update results in duplicate code', ->
      sampleFare.code = 'FCO'
      api.post("/fares/#{ sampleFare.id }")
      .send sampleFare
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###
  describe 'DELETE /:fareId [Delete a fare]', ->
    it 'should return success', ->
      api.del("/fares/#{ sampleFare.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid service id', ->
      api.del("/fares/#{ sampleFare.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false