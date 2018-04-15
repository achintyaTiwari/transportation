describe 'Users Endpoint {/users}', ->

  describe 'POST / [Create a new user]', ->
    #pass
    it 'should return bad request for missing params', ->
      api.post('/users')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create a new conductor', ->

      api.post('/users')
      .send testData.conductor
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.conductor.id = res.body.data.id
        testData.conductor.created = true
     ###
    it 'should return success with existing id for an existing mobile number', ->
      api.post('/users')
      .send testData.fixtures.conductor.data
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        res.body.data.id.should.equal testData.conductor.id
      ###
    it 'should create a new commuter', ->
      api.post('/users')
      .send testData.commuter
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.commuter.id = res.body.data.id
        testData.commuter.created = true

  describe 'GET / [List of users]', ->
    it 'should return success with commuters list', ->
      api.get('/users')
      .query({type:"COMMUTER"})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.commuter.id)

    it 'should return success with conductors list', ->
      api.get('/users')
      .query({type:"CONDUCTOR"})
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.conductor.id)

  describe 'POST /:userId [Update details of a particular user]', ->
    it 'should update only the given fields of a user', ->
      api.post("/users/#{ testData.commuter.id }")
      .send({ password: testData.commuter.password, status: CONST.STATUS.ACTIVE })
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.status.should.equal true
        testData.commuter.id = res.body.data.id

    it 'should return success with active users list', ->
      api.get('/users')
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        _.findKey(res.body.data, {id: testData.commuter.id}).should.not.be.undefined

  describe 'GET /:userId [Get details of a particular user]', ->
    it 'should return the correct conductor', ->
      api.get("/users/#{ testData.conductor.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.conductor.id

    it 'should return the correct commuter', ->
      api.get("/users/#{ testData.commuter.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.commuter.id
    #pass
    it 'should return not found on invalid user id', ->
      api.get("/users/invalid-#{ testData.commuter.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /login [Authenticate the user and generate session token for api calls]', ->
    it 'should be able to login with email, password combination', ->
      api.post("/users/login")
      .send({
          username: testData.commuter.email_address
          password: testData.commuter.password
          type: 'commuter'
      })
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property 'session_token'
        testData.commuter.token = res.body.data.session_token

    it 'should be able to login with mobile, password combination, and return the existing session', ->
      api.post("/users/login")
      .send({
          username: testData.commuter.mobile_number
          password: testData.commuter.password
          type: 'commuter'
      })
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('session_token').and.equal testData.commuter.token

    it 'should return bad request on invalid login credentials', ->
      api.post("/users/login")
      .send({username: testData.commuter.email_address, password: 'invalid-password'})
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /me [User profile]', ->
    #pass
    it 'should throw unauthorized on missing session token', ->
      api.get("/users/me")
      .expect HTTP_STATUS_CODES.UNAUTHORIZED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should be able to send session token and retrieve own profile', ->
      api.get("/users/me")
      .set('Authorization', testData.commuter.token)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.commuter.id

    it 'should return current assignment as part of profile in case of conductor', ->
      api.get("/users/me")
      .set('Authorization', testData.tokens.conductor)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal 'test-conductor'
        #res.body.data.should.have.property('assignment').and.that.is.an('object')

#  describe 'GET /otp [Get OTP for user login]', ->
#    @timeout 5000
#    it 'should return the correct user id', ->
#      api.get("/users/otp")
#      .query({mobile_number: testData.mobile_number})
#      .expect HTTP_STATUS_CODES.OK
#      .expect 'Content-Type', /json/
#      .expect (res)->
#        if err then return done(err)
#        res.body.should.have.property('status').and.equal true
#        res.body.should.have.property('data').and.that.is.an('object')
#        res.body.data.user_id.should.equal testData.otpUser.id
#        done()

  describe 'POST /logout [Logout and delete the session token]', ->
    it 'should be able to logout by passing session token', ->
      api.post("/users/logout")
      .set('Authorization', testData.commuter.token)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

  describe 'DELETE /:userId [Delete a user]', ->
    it 'should return success after deleting commuter', ->
      api.del("/users/#{ testData.commuter.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        testData.commuter.created = false

    it 'should return success after deleting conductor', ->
      api.del("/users/#{ testData.conductor.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        testData.conductor.created = false
    #pass
    it 'should return not found on invalid user id', ->
      api.del("/users/#{ testData.commuter.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false
