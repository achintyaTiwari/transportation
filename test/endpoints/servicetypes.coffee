describe 'ServiceTypes Endpoint {/serviceTypes}', ->

  sampleServiceType =
    operator_id: 'invalid-operator'
    name: 'Sample Service Type'
    code: helpers.random.generate(3)
    seating_capacity: 38
    min_fare: 0.00
    service_tax: 5.05
    toll_charge: 6.10
    cess: 2.25
    round_off: 1
    stage_fares: [1, 2, 4, 6, 8, 10]
    luggage_fare_id: 'test-luggage-fare'
    is_pass_allowed: true
    is_concession_allowed: false

  describe 'POST / [Create a new service type]', ->
    it 'should return bad request for missing params', ->
      api.post('/serviceTypes')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      api.post('/serviceTypes')
        .send sampleServiceType
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should create a new service type', ->
      sampleServiceType.operator_id = 'test-operator'
      api.post('/serviceTypes')
        .send sampleServiceType
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.should.have.property 'id'
          sampleServiceType.id = res.body.data.id
     ###
    it 'should return bad request for duplicate code', ->
      api.post('/serviceTypes')
        .send sampleServiceType
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
     ###
  describe 'GET / [List of service types]', ->
    it 'should return bad request on missing operator id', ->
      api.get('/fares')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return success with list of service types', ->
      api.get('/serviceTypes')
        .query {operator_id:sampleServiceType.operator_id}
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('array')
          res.body.data.should.contain.an.item.with.property('id', sampleServiceType.id)

  describe 'GET /:serviceTypeId [Get details of particular service type]', ->
    it 'should return a proper service type object', ->
      api.get("/serviceTypes/#{ sampleServiceType.id }")
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.id.should.equal sampleServiceType.id
          res.body.data.should.have.property('cess').and.equal sampleServiceType.cess
          res.body.data.should.have.property('round_off').and.equal sampleServiceType.round_off
          res.body.data.should.have.property('stage_fares').and.that.is.an('array').lengthOf sampleServiceType.stage_fares.length

    it 'should return not found on invalid service type id', ->
      api.get("/serviceTypes/invalid-#{ sampleServiceType.id }")
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
   
  describe 'POST /:serviceId [Update service type details]', ->
    
    it 'should update only the name and return the updated service type', ->
      sampleServiceType.name = 'Updated ' + sampleServiceType.name
      api.post("/serviceTypes/#{ sampleServiceType.id }")
        .send sampleServiceType
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.name.should.equal sampleServiceType.name

      ###

    it 'should return bad request for an update results in duplicate code', ->
      api.post("/serviceTypes/test-service-type")
        .send sampleServiceType
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
    ###
  describe 'DELETE /:serviceTypeId [Delete a service type]', ->
    it 'should return success', ->
      api.del("/serviceTypes/#{ sampleServiceType.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
     ###
    it 'should return not found on invalid service id', ->
      api.del("/serviceTypes/#{ sampleServiceType.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
    ###