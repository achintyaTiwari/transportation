describe 'PaymentMethods Endpoint {/paymentMethods}', ->

  samplePaymentMethod =
    operator_id: 'invalid-operator'
    name: "Sample Payment Method"

  describe 'POST / [Create a new payment method]', ->
    it 'should return bad request for missing params', ->
      api.post('/paymentMethods')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      api.post('/paymentMethods')
        .send samplePaymentMethod
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should create a new payment method', ->
      samplePaymentMethod.operator_id = 'test-operator'
      api.post('/paymentMethods')
        .send samplePaymentMethod
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.should.have.property 'id'
          samplePaymentMethod.id = res.body.data.id
    ###
    it 'should return bad request for duplicate name', ->
      api.post('/paymentMethods')
        .send samplePaymentMethod
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
    ###
  describe 'GET / [List of payment methods]', ->
    it 'should return bad request on missing operator id', ->
      api.get('/paymentMethods')
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

    it 'should return success with list of payment methods', ->
      api.get('/paymentMethods')
        .query {operator_id: samplePaymentMethod.operator_id}
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('array')
          res.body.data.should.contain.an.item.with.property('id', samplePaymentMethod.id)

  describe 'GET /:paymentMethodId [Get details of particular payment method]', ->
    it 'should return a proper payment method object', ->
      api.get("/paymentMethods/#{ samplePaymentMethod.id }")
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.id.should.equal samplePaymentMethod.id

    it 'should return not found on invalid payment method id', ->
      api.get("/paymentMethods/invalid-#{ samplePaymentMethod.id }")
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false

  describe 'POST /:paymentMethodId [Update payment method details]', ->
    it 'should update only the name and return the updated payment method', ->
      samplePaymentMethod.name = 'Updated ' + samplePaymentMethod.name
      api.post("/paymentMethods/#{ samplePaymentMethod.id }")
        .send samplePaymentMethod
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property('data').and.that.is.an('object')
          res.body.data.name.should.equal samplePaymentMethod.name
    ###
    it 'should return bad request for an update results in duplicate object', ->
      api.post("/paymentMethods/test-payment-method")
        .send samplePaymentMethod
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
    ###
  describe 'DELETE /:paymentMethodId [Delete a payment method]', ->
    it 'should return success', ->
      api.del("/paymentMethods/#{ samplePaymentMethod.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid payment method id', ->
      api.del("/paymentMethods/#{ samplePaymentMethod.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.NOT_FOUND
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false