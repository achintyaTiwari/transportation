describe 'Routes Endpoint {/routes}', ->

  describe 'POST / [Create a new route]', ->
    it 'should return bad request for missing params', ->
      api.post('/routes')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      api.post('/routes')
        .send testData.route
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
          testData.route.operator_id = 'test-operator'

    it 'should return bad request on invalid service type', ->
      api.post('/routes')
        .send testData.route
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
          testData.route.service_type_id = 'test-service-type'

    it 'should return bad request on invalid fare type', ->
      api.post('/routes')
        .send testData.route
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
          testData.route.fare_type = 'stage'

    it 'should create a new route', ->
      api.post('/routes')
        .send testData.route
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.should.have.property 'id'
          testData.route.id = res.body.data.id

    it 'should return bad request for duplicate name', ->
      api.post('/routes')
        .send testData.route
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

  describe 'GET / [List of routes]', ->
    it 'should return success with routes', ->
      api.get('/routes')
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('array')
          res.body.data.should.contain.an.item.with.property('id', testData.route.id)

  describe 'GET /:routeId [Get details of particular route]', ->
    it 'should return a proper route object', ->
      api.get("/routes/#{ testData.route.id }")
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.id.should.equal testData.route.id

    it 'should return not found on invalid route id', ->
      api.get("/routes/invalid-#{ testData.route.id }")
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

  describe 'POST /:routeId [Update route details]', ->
    it 'should update only the name and return the updated route', ->
      testData.route.name = 'Updated ' + testData.route.name
      api.post("/routes/#{ testData.route.id }")
        .send testData.route
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.name.should.equal testData.route.name

    it 'should return bad request for an update results in duplicate name', ->
      api.post("/routes/test-route")
        .send testData.route
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

  describe 'DELETE /:routeId [Delete a route]', ->
    it 'should return success', ->
      api.del("/routes/#{ testData.route.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid route id', ->
      api.del("/routes/#{ testData.route.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false