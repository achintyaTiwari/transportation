sampleOrderPass =
  type: 'pass'
  product_id: 'invalid-product'
  schedule_id: 'invalid-schedule'
  amount: 100
  payment:
    id: 'pay_5AEtSrqD6oBADJ'

sampleOrderPassengerTicket =
  type: 'passenger_ticket'
  schedule_id: 'invalid-schedule'
  from: 'test-stop'
  to: 'test-stop'
  payment:
    id: 'pay_5AEtSrqD6oBADJ'

sampleOrderOnlineBooking =
  type: 'online_booking'
  schedule_id: 'invalid-schedule'
  first_name: 'first'
  last_name: 'last'
  mobile_number: helpers.random.generate({length: 10, charset: 'numeric'})
  seat_number: '11U'
  from: 'test-stop'
  to: 'test-stop'
  payment:
    id: 'pay_5AEtSrqD6oBADJ'
describe 'Orders Endpoint {/orders}', ->
  describe 'POST / [Create a new order type of pass]', ->
    it 'should return bad request on missing required params', ->
      api.post('/orders')
      .set('Authorization', testData.tokens.commuter)
      .send _.omit(sampleOrderPass, 'type')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid product', ->
      api.post('/orders')
      .set('Authorization', testData.tokens.commuter)
      .send sampleOrderPass
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create a new order', ->
      
      sampleOrderPass.product_id = 'test-product'
      sampleOrderPass.schedule_id = 'test-schedule'
      sampleOrderPass.trip_id = 'test-trip'
      sampleOrderPass.operator_id = 'test-operator' 

      api.post('/orders')
      .set('Authorization', testData.tokens.commuter)
      .send sampleOrderPass
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.product.should.have.property('id').and.equal 'test-product'
        res.body.data.type.should.equal sampleOrderPass.type.toUpperCase()
        res.body.data.status.should.equal 'CREATED'
        sampleOrderPass.id = res.body.data.id

  describe 'POST / [Create a new order type of passenger_ticket]', ->
    it 'should return bad request on missing required params', ->
      api.post('/orders')
        .set('Authorization', testData.tokens.commuter)
        .send _.omit(sampleOrderPassengerTicket, ['from', 'to'])
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
    
    it 'should create a new order', ->
      api.post('/orders')
        .set('Authorization', testData.tokens.commuter)
        .send sampleOrderPassengerTicket
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.product.should.have.property('journey')
          res.body.data.type.should.equal sampleOrderPassengerTicket.type.toUpperCase()
          res.body.data.status.should.equal 'CREATED'
          sampleOrderPassengerTicket.id = res.body.data.id
    
  describe 'POST / [Create a new order type of online_booking]', ->
    it 'should return bad request on missing required params', ->
      api.post('/orders')
        .set('Authorization', testData.tokens.commuter)
        .send _.omit(sampleOrderOnlineBooking, ['type', 'seat_number', 'from', 'to'])
        .expect HTTP_STATUS_CODES.BAD_REQUEST
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal false
  
    it 'should create a new order', ->
      api.post('/orders')
        .set('Authorization', testData.tokens.commuter)
        .send sampleOrderOnlineBooking
        .expect HTTP_STATUS_CODES.CREATED
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true
          res.body.should.have.property 'data'
          res.body.data.product.should.have.property('journey')
          res.body.data.type.should.equal sampleOrderOnlineBooking.type.toUpperCase()
          res.body.data.status.should.equal 'CREATED'
          sampleOrderOnlineBooking.id = res.body.data.id
    
  describe 'GET / [List of orders]', ->
    it 'should return success with orders', ->
      api.get('/orders')
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', sampleOrderPass.id)

    it 'should return success with orders grouped', ->
      api.get('/orders')
      .query {group_by: 'payment_method'}
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')

  describe 'GET /:orderId [Get details of particular order]', ->
    it 'should return the correct order', ->
      api.get("/orders/#{ sampleOrderPass.id }")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal sampleOrderPass.id

    it 'should return not found on invalid order id', ->
      api.get("/orders/invalid-#{ sampleOrderPass.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:orderId/payment [Update payment details for an order]', ->
    it 'should expect an object with key payment in req body', ->
      api.post("/orders/#{ sampleOrderPass.id }/payment")
      .set('Authorization', testData.tokens.commuter)
      .send sampleOrderPass.payment
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should bad request for invalid payment ref', ->
      @timeout 0
      api.post("/orders/#{ sampleOrderPass.id }/payment")
      .set('Authorization', testData.tokens.commuter)
      .send {payment: sampleOrderPass.payment}
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should marked the payment as payment failed', ->
      api.get("/orders/#{ sampleOrderPass.id }")
      .set('Authorization', testData.tokens.commuter)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.should.have.property('status').and.equal 'PAYMENT_FAILED'

  describe 'DELETE /:orderId [Delete a order]', ->
    it 'should return success', ->
      api.del("/orders/#{ sampleOrderPass.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return success', ->
      api.del("/orders/#{ sampleOrderPassengerTicket.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true

    it 'should return success', ->
      api.del("/orders/#{ sampleOrderOnlineBooking.id }")
        .set('Authorization', testData.tokens.admin)
        .expect HTTP_STATUS_CODES.OK
        .expect 'Content-Type', /json/
        .expect (res)->
          res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid order id', ->
      api.del("/orders/#{ sampleOrderPass.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false