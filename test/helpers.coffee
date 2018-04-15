rand = require  'randomstring'
uuid = require 'uuid'
moment = require 'moment'
fixtures = require './fixtures'

helpers = {
  random: rand
  testData: {
    fixtures: fixtures
    tokens: {}
    email: {
      from_address: "test@journee.in"
      to_address: 'anurag4141@gmail.com'
      to_name: 'Sankaran'
      subject: 'Test'
      message: 'All is well!'
    }
    operator: {
      name: 'Test Operator'
      home_state_id:'KN'
      operating_states:['KM']

    }
    conductor: 
      first_name: 'Test'
      last_name: 'Conductor'
      email_address: "#{rand.generate()}@example.com"
      mobile_number: rand.generate({length: 10, charset: 'numeric'})
      alt_mobile_numbers: [
        rand.generate({length: 10, charset: 'numeric'})
        ]
      password: rand.generate()
      pin:rand.generate({length:6,charset: 'numeric'})
      preferances:"W"
      type: "CONDUCTOR"
    commuter: {
      first_name: 'Test'
      last_name: 'Commuter'
      email_address: "#{rand.generate()}@example.com"
      mobile_number: rand.generate({length: 10, charset: 'numeric'})
      alt_mobile_numbers: [
        rand.generate({length: 10, charset: 'numeric'})
      ]
      password: rand.generate()
      pin:rand.generate({length:6,charset: 'numeric'})
      preferances:"W" 
      type: "COMMUTER"
    }
    stop: {
      operator_id:'test-operator'
      code:'50OFF'
      name: "#{rand.generate()} Station"
      regional_name: 'ಕೆಂಪೇಗೌಡ ಅಂತಾರಾಷ್ಟ್ರೀಯ ವಿಮಾನ'
      place_id: rand.generate()
      lat:12.978029 
      lon:77.572352
      state_id:'KN'
    }
    
    route: {
      operator_id: 'invalid-operator'
      name: "#{rand.generate()} Route"
      service_type_id: 'invalid-service-type'
      depot_id:'invalid-depot-id'
      fare_type: 'STAGE'
      stops: [{
        stop_id: 'test-stop'
        seq: 1
        is_stage: true
        arrive_in_mins: 0
        depart_in_mins: 0
        toll_plaza_count: 1
        distance: 0
        fare: 0
      }, {
        stop_id: 'test-stop'
        seq: 2
        is_stage: false
        arrive_in_mins: 20
        depart_in_mins: 25
        toll_plaza_count: 0
        distance: 20
        fare: 20.20
      }]
    }
    
    schedule: {
      service_code:'SER'
      route_id: 'invalid-route'
      depart_at: '0830'
      arrive_at: '1015'
      direction: 'down'
    }
    depot: {
      name: "#{rand.generate()} Depot"
      operator_id: 'invalid-operator'
    }
    vehicle: {
      operator_id: 'invalid-operator'
      depot_id: 'invalid_depot'
      reg_number: 'KA-01-AZ-9876'
      capacity: 100
    }
    assignment: {
      operator_id: 'invalid-operator'
      driver_id: 'invalid-driver'
      conductor_id: 'invalid-conductor'
      vehicle_id: 'invalid-vehicle'
      device_id: 'invalid-device'
      schedule_ids: ['invalid-schedule']
    }
    product: {
      
      name: 'Daily Pass'
      desc: 'Description'
      price: 100
      validity: 10
      validity_type: 'day'
      operator: 'invalid-operator'
      services: [fixtures.serviceType.data._id]
    }
    trip: {
      assignment_id: 'invalid-assignment'
      schedule_id: 'invalid-schedule'
      lat: 12.978029
      lon: 77.572352
    }
    journey: {
      trip_id: 'invalid-trip'
      order_id: 'invalid-order'
      stage: 1
      lat: 12.978029
      lon: 77.572352
    }

  }
}

module.exports = helpers