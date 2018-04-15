describe 'Products Endpoint {/products}', ->

  describe 'POST / [Create a new product]', ->
    it 'should return bad request for missing params', ->
      api.post('/products')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on invalid operator', ->
      api.post('/products')
      .send testData.product
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should return bad request on missing required params', ->
      testData.product.operator_id = 'test-operator'
      api.post('/products')
      .send _.omit(testData.product, 'price', 'name')
      .expect HTTP_STATUS_CODES.BAD_REQUEST
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

    it 'should create a new product', ->
      api.post('/products')
      .send testData.product
      .expect HTTP_STATUS_CODES.CREATED
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property 'data'
        res.body.data.should.have.property 'id'
        testData.product.id = res.body.data.id

  describe 'GET / [List of products]', ->
    it 'should return success with products', ->
      api.get('/products')
      .query {operator_id:"test-operator"}
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('array')
        res.body.data.should.contain.an.item.with.property('id', testData.product.id)

  describe 'GET /:productId [Get details of particular product]', ->
    it 'should return the correct product', ->
      api.get("/products/#{ testData.product.id }")
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.id.should.equal testData.product.id

    it 'should return not found on invalid product id', ->
      api.get("/products/invalid-#{ testData.product.id }")
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false

  describe 'POST /:productId [Update product details]', ->
    it 'should update only the name and return the updated product', ->
      testData.product.name = 'Updated ' + testData.product.name
      api.post("/products/#{ testData.product.id }")
      .send testData.product
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true
        res.body.should.have.property('data').and.that.is.an('object')
        res.body.data.name.should.equal testData.product.name

  describe 'DELETE /:productId [Delete a product]', ->
    it 'should return success', ->
      api.del("/products/#{ testData.product.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.OK
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal true

    it 'should return not found on invalid product id', ->
      api.del("/products/#{ testData.product.id }")
      .set('Authorization', testData.tokens.admin)
      .expect HTTP_STATUS_CODES.NOT_FOUND
      .expect 'Content-Type', /json/
      .expect (res)->
        res.body.should.have.property('status').and.equal false