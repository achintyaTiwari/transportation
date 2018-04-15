describe 'Vehicles Endpoint {/vehicles}', ->
  
  describe 'POST / [Create a new vehicle]', ->
    #pass
    it 'should return bad request for missing params', ->
      api.post('/vehicles')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
     #pass
    it 'should return bad request on invalid operator', ->
      api.post('/vehicles')
      .send testData.vehicle
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
      #pass
    it 'should return bad request on invalid depot', ->
      testData.vehicle.operator_id = 'test-operator'
      api.post('/vehicles')
      .send testData.vehicle
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
      #pass
    it 'should create a new vehicle', ->
      testData.vehicle.depot_id = 'test-depot'
      api.post('/vehicles')
      .send testData.vehicle
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.vehicle.id = res.body.data.id
     ### 
    it 'should return bad request for duplicate registration number', ->
      api.post('/vehicles')
      .send testData.vehicle
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
     ###
  describe 'GET / [List of vehicles]', ->
     #pass
    it 'should return success with vehicles', ->
      api.get("/vehicles?operator_id=#{testData.vehicle.operator_id}")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.vehicle.id)
        res.body.data.should.contain.an.item.with.property('id', 'test-vehicle')
        testData.vehicle.vin = _.find(res.body.data, {id: testData.vehicle.id}).vin
        testData.fixtures.vehicle.data.vin = _.find(res.body.data, {id: 'test-vehicle'}).vin
    ###
    it 'should be possible to search by vehicle identification number (vin)', ->
      api.get("/vehicles")
      .query({vin: testData.fixtures.vehicle.data.vin})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', 'test-vehicle')
        res.body.data.should.contain.an.item.with.property('id', 'test-vehicle')
        _.first(res.body.data).should.have.property('route').and.that.is.an('object')
          #pass
    it 'should be possible to batch search by vehicle identification number (vin)', ->
      api.get('/vehicles')
      .query({vin: [testData.fixtures.vehicle.data.vin, testData.vehicle.vin]})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array').and.of.length 2
        res.body.data.should.contain.an.item.with.property('id', 'test-vehicle')
        res.body.data.should.contain.an.item.with.property('id', testData.vehicle.id)

    it 'should exclude invalid vin and return result only for valid vin', ->
      api.get('/vehicles')
      .query({vin: [testData.fixtures.vehicle.data.vin, 'invalid-vin']})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array').and.of.length 1
        res.body.data.should.contain.an.item.with.property('id', 'test-vehicle')
     
    it 'should exclude invalid vin and return empty result when none of the vin is valid', ->
      api.get('/vehicles')
      .query({vin: ['invalid-vin1', 'invalid-vin2']})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array').and.is.empty
  
     ###
  describe 'GET /:vehicleId [Get details of particular vehicle]', ->
    it 'should return the correct vehicle', ->
      api.get("/vehicles/#{ testData.vehicle.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.vehicle.id

        #res.body.data.should.have.property('vin').and.that.is.of.length 8

     #pass
    it 'should return not found on invalid vehicle id', ->
      api.get("/vehicles/invalid-#{ testData.vehicle.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:vehicleId [Update vehicle details]', ->
     #pass
    it 'should update only the capacity and return the updated vehicle', ->
      testData.vehicle.capacity = 1000
      api.post("/vehicles/#{ testData.vehicle.id }")
      .send testData.vehicle
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.capacity.should.equal testData.vehicle.capacity

  describe 'DELETE /:vehicleId [Delete a vehicle]', ->
       #pass    
    it 'should return success', ->
      api.del("/vehicles/#{ testData.vehicle.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid vehicle id', ->
       #pass      
      api.del("/vehicles/#{ testData.vehicle.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false