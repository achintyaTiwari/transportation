describe 'Assignments Endpoint {/assignments}', ->

  describe 'POST / [Create a new assignment]', ->
     ###
    it 'should return unauthorized for missing session token', ->
      api.post('/assignments')
      .expect HTTP_STATUS_CODES.UNAUTHORIZED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
      
    it 'should return forbidden if the user is not authorized to create an assignment', ->
      api.post('/assignments')
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.FORBIDDEN
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
     ###
    it 'should return bad request for missing params', ->
      api.post('/assignments')
      #.set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      api.post('/assignments')
      #.set('Authorization', testData.tokens.admin)
      .send testData.assignment
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid conductor', ->
      testData.assignment.operator_id = 'test-operator'
      api.post('/assignments')
      #.set('Authorization', testData.tokens.admin)
      .send testData.assignment
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid vehicle', ->
      testData.assignment.conductor_id = 'test-conductor'
      api.post('/assignments')
      #.set('Authorization', testData.tokens.admin)
      .send testData.assignment
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid device', ->
      testData.assignment.vehicle_id = 'test-vehicle'
      testData.assignment.schedule_ids = ['test-schedule']
      api.post('/assignments')
      #.set('Authorization', testData.tokens.admin)
      .send testData.assignment
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create a new assignment', ->
      testData.assignment.device_id = 'test-device'
      # We have created assignment with test-assignment already for testing
      # so without 'ignore_ongoing' this test case will fail
      api.post('/assignments?ignore_ongoing=true')
      #.set('Authorization', testData.tokens.admin)
      .send testData.assignment
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.assignment.id = res.body.data.id

    it 'should return bad request for duplicate ongoing assignment', ->
      api.post('/assignments')
      .set('Authorization', testData.tokens.admin)
      .send testData.assignment
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'GET / [List of assignments]', ->
    it 'should return success with assignments', ->
    api.get('/assignments')
      .query ({operator_id:testData.assignment.operator_id})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.assignment.id)

  describe 'GET /:assignmentId [Get details of particular assignment]', ->
    it 'should return the correct assignment', ->
      api.get("/assignments/#{ testData.assignment.id }")
      #.set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.assignment.id

    it 'should return not found on invalid assignment id', ->
      api.get("/assignments/invalid-#{ testData.assignment.id }")
      #.set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
    ###
  describe 'POST /:assignmentId/status [Report status of particular assignment]', ->
    it 'should return forbidden for invalid token', ->
      api.post("/assignments/#{ testData.assignment.id }/status")
      .send testData.assignmentStatusUpdate
      #.set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.FORBIDDEN
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
   
    it 'should process the updates and return accepted status on valid token', ->
      api.post("/assignments/#{ testData.assignment.id }/status")
      .send testData.assignmentStatusUpdate
      #.set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.ACCEPTED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.assignment.id
     
    it 'bulk update should have created a new trip', ->
      tripIndex = _.findIndex(testData.assignmentStatusUpdate.updates, {update_type: 'trip'})
      tripId = testData.assignmentStatusUpdate.updates[tripIndex].id
      api.get("/trips/#{ tripId }")
      #.set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal tripId
    ###        
  describe 'DELETE /:assignmentId [Delete a assignment]', ->
    it 'should return success', ->
      api.del("/assignments/#{ testData.assignment.id }")
      #.set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid assignment id', ->
      api.del("/assignments/#{ testData.assignment.id }")
      #.set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false