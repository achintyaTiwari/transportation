rand = require 'randomstring'

module.exports = {
  operator:
    modelName: 'Operator'
    data:
      _id: 'test-operator'
      name: 'Test-Transport-Operator'
      name_slug: 'operator-slug'
      home_state:"KA"
      operating_states:["KA","TN","UP"]
      status:1

  admin:
    modelName: 'User'
    data:
      _id: 'test-admin'
      first_name: 'Test'
      last_name: 'Admin'
      mobile_number: "9751662544"
      alt_mobile_numbers:["9731#{rand.generate({length: 6, charset: 'numeric'})}","9731#{rand.generate({length: 6, charset: 'numeric'})}"]
      email_address: "#{rand.generate()}@example.com"
      password: 'test'
      pin:'123456'
      otp:'432178'
      avatar:'IronMan'
      operator:'test-operator00'
      preferences:'W'
      type: 'ADMIN'
      status:1
  commuter:
    modelName: 'User'
    data:
      _id: 'test-commuter'
      first_name: 'Test'
      last_name: 'Commuter'
      mobile_number: "9731#{rand.generate({length: 6, charset: 'numeric'})}"
      alt_mobile_numbers:["9731#{rand.generate({length: 6, charset: 'numeric'})}","9731#{rand.generate({length: 6, charset: 'numeric'})}"]
      email_address: "#{rand.generate()}@example.com"
      password: 'test'
      pin:'123456'
      otp:'432178'
      avatar:'Hulk'
      operator: 'test-operator'
      preferences:'W'
      type: 'COMMUTER'
      status:1
  conductor:
    modelName: 'User'
    data:
      _id: 'test-conductor'
      first_name: 'Test'
      last_name: 'Conductor'
      mobile_number: "9731#{rand.generate({length: 6, charset: 'numeric'})}"
      alt_mobile_numbers:["9731#{rand.generate({length: 6, charset: 'numeric'})}","9731#{rand.generate({length: 6, charset: 'numeric'})}"]
      email_address: "#{rand.generate()}@example.com"
      password: 'test'
      pin:'123456'
      otp:'432178'
      avatar:'Dr. Strange'
      operator: 'test-operator'
      preferences:'W'
      type: 'CONDUCTOR'
      status:1
  driver:
    modelName: 'User'
    data:
      _id: 'test-driver'
      first_name: 'Test'
      last_name: 'Driver'
      mobile_number: "9731#{rand.generate({length: 6, charset: 'numeric'})}"
      alt_mobile_numbers:["9731#{rand.generate({length: 6, charset: 'numeric'})}","9731#{rand.generate({length: 6, charset: 'numeric'})}"]
      email_address: "#{rand.generate()}@example.com"
      password: 'test'
      pin:'123456'
      otp:'432178'
      avatar:'DeadPool'
      operator: 'test-operator'
      preferences:'W'
      type: 'DRIVER'
      status:1
  depot:
    modelName: 'Depot'
    data:
      _id: 'test-depot'
      name: 'Test Depot'
      operator: 'test-operator'
      status:1
  concession:
    modelName: 'Concession'
    data:
      _id: 'test-concession'
      operator: 'test-operator'
      names: '45% off'
      code: '45OFF'
      reduction_value: 45
      reduction_type: 'percentage'
      status:1
  stop:
    modelName: 'Stop'
    data:
      _id: 'test-stop01'
      operator:'test-operator'
      code:'AloeMora'
      name: 'Kempegowda International Airport'
      regional_name: 'ಕೆಂಪೇಗೌಡ ಅಂತಾರಾಷ್ಟ್ರೀಯ ವಿಮಾನ'
      place_id: 'ChIJk6KlzvsUrjsR-ZcHnz8V1k4'
      location:
        type:'Point'
        coordinates: [77.5723521, 12.9779977]
      state: 'test-state'
  paymentMethod:
    modelName: 'PaymentMethod'
    data:
      _id: 'test-payment-method'
      operator: 'test-operator'
      name: 'Cash'
      status:1
  fare:
    modelName: 'Fare'
    data:
      _id: 'test-luggage-fare'
      operator: 'test-operator'
      name: 'City Ordinary'
      code: 'FCO'
      slabs: [{
        name: '0-25'
        value: 1.25
      }, {
        name: '26-50'
        value: 3.00
      }]
      type: 'luggage'
      status:1
  serviceType:
    modelName: 'ServiceType'
    data:
      _id: 'test-service-type'
      operator: 'test-operator'
      name: 'Vayu Vajra'
      code: 'VVJ'
      seating_capacity: 45
      basic_fare:0.00
      minimum_fare: 0.00
      stage_distance_in_kms:0.00
      stage_duration_in_mins:0.00
      stage_fares: [1, 2, 4, 6, 8, 10]
      luggage_fare: 'test-luggage-fare'
      service_tax: 0.00
      toll_charge: 0.00
      cess: 0.00
      round_off: 1
      is_pass_allowed: true
      is_concession_allowed: false
      payment_methods:["stripe","paymentMethod"]
      status:1
  route:
    modelName: 'Route'
    data:
      _id: 'test-route'
      operator: 'test-operator'
      depot: 'test-depot'
      name: '25A'
      service_type: 'test-service-type'
      fare_type: 'stage'
      stops: [{
        seq: 1
        stop: 'test-stop'
        is_stage: true
        arrive_in_mins: 0
        depart_in_mins: 0
        toll_plaza_count: 1
        distance: 0
        fare: 0
      }, {
        seq: 2
        stop: 'test-stop'
        is_stage: false
        arrive_in_mins: 20
        depart_in_mins: 25
        toll_plaza_count: 0
        distance: 20
        fare: 25
      }]
      status:1
  schedule:
    modelName: 'Schedule'
    data:
      _id: 'test-schedule'
      service_code: 'SC07'
      route: 'test-route'
      depart_at: '0755'
      arrive_at: '0910'
      direction: 'down'
      status:1
  vehicle:
    modelName: 'Vehicle'
    data:
      _id: 'test-vehicle'
      operator: 'test-operator'
      depot: 'test-depot2'
      reg_number: 'KA-51-F-' + rand.generate({length: 4, charset: 'numeric'})
      capacity: 10
      status:1
  device:
    modelName: 'Device'
    data:
      _id: 'test-device'
      operator: 'test-operator'
      application: 'test-application'
      depot: 'test-depot'
      mac: rand.generate()
      uuid: rand.generate()
      imei: rand.generate({length: 15, charset: 'numeric'})
      token: rand.generate()
      meta_data:"meta_data"
      status:1
  waybill:
    modelName: 'Assignment'
    data:
      _id: 'test-assignment'
      operator: 'test-operator'
      driver: 'test-driver'
      conductor: 'test-conductor'
      device: 'test-device'
      vehicle: 'test-vehicle'
      abstract_id:'test-id'
      route: 'test-route'
      schedules:['schedule1','schedule2']
      order_seq_start:2
      repeats:true
      status:1
  trip:
    modelName: 'Trip'
    data:
      _id: 'test-trip01'
      waybill:'test-assignment'
      schedule: 'test-schedule'
      start: {
        location: 'KBS'
        datetime: moment()
      }
      end: {
        location: 'UP'
        datetime: moment()
      }
      hash: 'test-trip-hash'
      secret_key: new Buffer(rand.generate(CONST.SECRET_KEY_LENGTH)).toString(CONST.BASE64)
      status: CONST.TRIP_STATUS.STARTED
  product:
    modelName: 'Product'
    data:
      _id: 'test-product'
      name: 'Daily Pass'
      desc: 'Description'
      price: 100
      validity: 10
      validity_type: CONST.VALIDITY_TYPE.DAY
      operator: 'test-operator'
      services: ['test-service']
      status:1
  order:
    modelName: 'Order'
    data:
      _id: 'test-order'
      seq:'1'
      users: ['test-commuter']
      schedule: 'test-schedule'
      product:
        _id: 'test-product'
        name: 'Daily Pass'
        desc: 'Description'
        price: 100
        validity: 1
        validity_type: CONST.VALIDITY_TYPE.JOURNEY
        operator: 'test-operator'
        servicetype_ids: ['test-service']
      amount: 100
      payment: 
        _id:'test-payment'
        method:'test-payment-method'
        meta_data:'test-meta-data'
      validity: 1
      validity_type: CONST.VALIDITY_TYPE.JOURNEY
      type: 'PASS'
      channel:
        id:'test-channel'
      status: CONST.ORDER_STATUS.ACTIVE
  journey:
    modelName: 'Journey'
    data:
      _id: 'test-journey'
      commuter: 'test-commuter'
      order: 'test-order'
      trip: 'test-trip'
      token: rand.generate()
      start: {
        stage: 1
        location: 'KBS'
        datetime: moment()
      }
      end: {
        stage: 1
        location: 'KBS'
        datetime: moment()
      }
      
      status: CONST.JOURNEY_STATUS.STARTED
}