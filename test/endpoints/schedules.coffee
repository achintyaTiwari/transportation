describe 'Schedules Endpoint {/schedules}', ->

  describe 'POST / [Create a new Schedule]', ->
    it 'should return bad request for missing params', ->
      api.post('/schedules')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return bad request for invalid route', ->
      api.post('/schedules')
        .send testData.schedule
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should create new schedule', ->
      testData.schedule.route_id = 'test-route'
      api.post('/schedules')
        .send testData.schedule
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.should.have.property 'id'
          testData.schedule.id = res.body.data.id

  #    it 'should return bad request for overlapping schedule', ->
  #      api.post('/schedules')
  #      .send testData.schedule
  #      .expect HTTP_STATUS_CODES.BAD_REQUEST
  #      .expect 'Content-Type', /json/
  #      .expect (res)->
  #        res.body.should.have.property('status').and.equal false

  describe 'GET / [List of schedules]', ->
    it 'should return success with schedules', ->
      api.get('/schedules')
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('array')
          res.body.data.should.contain.an.item.with.property('id', testData.schedule.id)

    it 'should be possible to search schedules by route', ->
      api.get('/schedules')
        .query({route_id: testData.schedule.route_id})
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('array')
          res.body.data.should.contain.an.item.with.property('id', testData.schedule.id)

  describe 'GET /:scheduleId [Get details of particular schedule]', ->
    it 'should return the proper schedule object', ->
      api.get("/schedules/#{ testData.schedule.id }")
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.id.should.equal testData.schedule.id

    it 'should return not found on invalid schedule id', ->
      api.get("/schedules/invalid-#{ testData.schedule.id }")
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

  describe 'POST /:scheduleId [Update schedule details]', ->
    it 'should update only the timings and return the updated schedule', ->
      testData.schedule.depart_at = '0900'
      testData.schedule.arrive_at = '1000'
      api.post("/schedules/#{ testData.schedule.id }")
        .send testData.schedule
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.depart_at.should.equal testData.schedule.depart_at
          res.body.data.arrive_at.should.equal testData.schedule.arrive_at

  #    it 'should return bad request for an update results in duplicate name', ->
  #      api.post("/schedules/test-schedule")
  #      .send testData.schedule
  #      .expect HTTP_STATUS_CODES.BAD_REQUEST
  #      .expect 'Content-Type', /json/
  #      .expect (res)->
  #        res.body.should.have.property('status').and.equal false

  describe 'DELETE /:scheduleId [Delete a schedule]', ->
    it 'should return success', ->
      api.del("/schedules/#{ testData.schedule.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid schedule id', ->
      api.del("/schedules/#{ testData.schedule.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false