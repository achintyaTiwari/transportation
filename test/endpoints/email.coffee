describe 'Email Endpoint {/email}', ->

  describe 'POST / [Send single email]', ->
    #changes by achintya
    this.timeout 15000
    
    it 'should return bad request for missing params', ->
      api.post('/email')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return bad request for invalid from email', ->
      testData.email._from_address = testData.email.from_address
      testData.email.from_address = "invalid-email-address"
      api.post('/email')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
          testData.email.from_address = testData.email._from_address

    it 'should return bad request for invalid to email', ->
      testData.email._to_address = testData.email.to_address
      testData.email.to_address = "invalid-email-address"
      api.post('/email')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
          testData.email.to_address = testData.email._to_address

    it 'should send a single email', ->
      api.post('/email')
        .send testData.email
        .expect HTTP_STATUS_CODES.ACCEPTED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true