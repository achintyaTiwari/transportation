


const ScheduleType = new GraphQLObjectType({
  name:"Schedule"
  description: "This represents an schedule"
  fields: () -> ({
      _id: {type: GraphQLString}
      service_code: {type: new GraphQLNonNull(GraphQLString)}
      route: {
      	type: RouteType
      	resolve: (route){
      		return _.find(Routes,a -> a._id == route._id)}
       }
      depart_at: {type: new GraphQLNonNull(GraphQLString)}
      arrive_at: {type: new GraphQLNonNull(GraphQLString)}
      direction: {type: new GraphQLEnumType({
        values:
        	UP:
        		value: 'UP'
        	DOWN:
        		value 'DOWN'

      	})}
      status:{type:(GraphQLInt)}
      })

	})


const PaymentMethodType = new GraphQLObjectType({
	name: 'PaymentMethod'
	description: "This represents payment method"
	fields: () -> ({
       _id: {type: GraphQLString}
       operator: {
       	type: OperatorType
       	resolve: (operator){
       		return _.find(Operator,a -> a._id == operator._id)
       	}
       }
       name: {type: new GraphQLNonNull(GraphQLString)}
       status:{type:(GraphQLInt)}
       

		})
	})

const UserType = new GraphQLObjectType({
	name: 'User'
	description: "This represents user type"
	fields: () -> ({
		_id: {type:(GraphQLString)}
		first_name: {type:(GraphQLString)}
		last_name: {type:(GraphQLString)}
		mobile_number: {type:(GraphQLInt)}
		alt_mobile_numbers: {type:(GraphQLInt)}
		email_address: {type:(GraphQLString)}
		password: {type:(GraphQLString)}
		pin: {type:(GraphQLString)}
		otp: {type:(GraphQLString)}
		avatar: {type:(GraphQLString)}
		operator: {
       	type: OperatorType
       	resolve: (operator){
       		return _.find(Operator,a -> a._id == operator._id)
       	}
       }
       preferences: {type:(GraphQLString)}
       type: {type:new GraphQLEnumType({
       	values:
       		ADMIN:
       			value: 'ADMIN'
       		OPERATOR_ADMIN:
        			value: 'OPERATOR_ADMIN'
       		DEPOT_ADMIN:
       			value: 'DEPOT_ADMIN'
       		CONDUCTOR:
       			value: 'CONDUCTOR'
       		DRIVER:
       			value: 'DRIVER'
       		COMMUTER:
       			value: 'COMMUTER'
       			})}
        status:{type:(GraphQLInt)}

		})
	})


const OperatorType = new GraphQLObjectType({
	name: "Operator"
	description: "This schema represents the operator"
	fields: ()-> ({
		_id: {type: (GraphQLString)}
		name: {type: new GraphQLNonNull(GraphQLString)}
		name_slug: {type: (GraphQLString)}
		home_state: {
			type: StateType
			resolve: (state){
				return _.find(State,a -> a._id == state._id)
			}
		}

		operating_states: {
			type:StateType
			resolve:(){
				return State
			}

		}
		status: {type: (GraphQLInt)}
		})
	})

const RouteType = new GraphQLObjectType({
	name: "Route"
	description: "This schema represents the route"
	fields: ()-> ({
		_id: {type: (GraphQLString)}
		operator: {
			type: OperatorType
			resolve: (operator){
				return _.find(Operator,a -> a._id == operator._id)

			}
		}
		depot: {
			type: DepotType
			resolve: (depot){
				return _.find(Depot,a -> a._id == depot._id)

				}

		}
		name: {type: (GraphQLString)}
		service_type: {
			type: new GraphQLNonNull(ServiceType)
			resolve: (service){
				return _.find(ServiceType,a -> a._id == operator._id)
			}
		}
		fare_type: {type: new GraphQLNonNull(new GraphQLEnumType({
			values:
				STAGE:
					value: 'STAGE'
				MATRIX:
					value: 'MATRIX'
				})
		)}
		stops: {
			type: StopType
			resolve: (stop){
				return stops
			}
		}
		status: {type: (GraphQLInt)}

	    })
    })

const StateType = new GraphQLObjectType({
	name: 'state'
	description: 'This represents the state'
	fields: ()->({
      
      _id: {type: (GraphQLString)}
      name: {type: new GraphQLNonNull(GraphQLString)}\
      regional_name: {type: (GraphQLString)}
      })

	})
const DepotType = new GraphQLObjectType({
	name: 'depot'
	description: 'This represents the depot'
	fields: ()->({
		_id: {type: (GraphQLString)}
		name: {type: (GraphQLString)}
		operator: {
          type: OperatorType
          resolve: (operator){
          	return _.find(Operator,a -> a._id == operator._id)
          }
        }
        status: {type: (GraphQLInt)}
        })


	}) 
const ServiceType = new GraphQLObjectType({
	name: 'serviceType'
	description: 'This represents the serviceType'
	fields: ()-> ({
		_id: {type: (GraphQLString)}
		operator: {
			type: OperatorType
			resolve: (operator){
				return _.find(Operator,a -> a._id == operator._id)
			}
		}
		name: {type: new GraphQLNonNull(GraphQLString)}
		code: {type: new GraphQLNonNull(GraphQLString)}
		seating_capacity: {type: (GraphQLInt)}
		basic_fare: {type: (GraphQLInt)}
		minimum_fare: {type: (GraphQLInt)}
		stage_distance_in_kms: {type: (GraphQLInt)}
		stage_duration_in_mins: {type: (GraphQLInt)}
		stage_fares: {type: (GraphQLInt)}
		luggage_fare: {
			type:FareType
			resolve:(fare){
				return _.find(Fares,a -> a._id == fare._id)
				}
			}
		service_tax: {type: (GraphQLInt)}
		toll_charge: {type: (GraphQLInt)}
		cess: {type: (GraphQLInt)}
		round_off: {type: (GraphQLInt)}
		is_pass_allowed: {type: (GraphQLInt)}
		is_concession_allowed: {type: (GraphQLInt)}
		payment_methods: {
			type: PaymentMethodType
		    resolve: (payment_methods){
		    	return _.find(PaymentMethod,a -> a._id == payment_methods._id)
		    	}
		    }
		status: {type: (GraphQLInt)}
		})	
	
	})

const StopType = new GraphQLObjectType({
	name: 'stop'
	description: 'This is used to represent stops'
	fields: () -> ({
		_id: {type: (GraphQLInt)}
		operator: {
			type: OperatorType
			resolve: (operator){
				return _.find(Operator,a -> a._id == operator._id)
			}
		}
		code: {type: new GraphQLNonNull(GraphQLString)}
		name: {type: new GraphQLNonNull(GraphQLString)}
		regional_name: {type: (GraphQLString)}
		place_id: {type: new GraphQLNonNull(GraphQLString)}
		location: {
			'type': {type: (GraphQLString)}
			coordinates: {type: new GraphQLNonNull(GraphQLInt)}
		}
		cordinates:{type: (GraphQLInt)}
		state: {
			type: StateType
			resolve: (state){
				return _.find(State,a -> a._id == state._id)
			}
		}

		})
	})

const FareType = new GraphQLObjectType({
	name: 'Fare'
	description: 'This represents the fare type'
	fields: ()-> ({
		_id: {type: (GraphQLString)}
		operator: {
			type: OperatorType
			resolve: (operator){
				return _.find(Operator,a -> a._id == operator._id)
			}
		}
		name: {type: (GraphQLString)}
		code: {type: (GraphQLString)}
		slabs: [{
			name: {type: new GraphQLNonNull(GraphQLString)}
			value: {type: new GraphQLNonNull(GraphQLInt)}
			}]
		type: {new GraphQLNonNull(new GraphQLEnumType({
			values:
				LUGGAGE:
					value: 'LUGGAGE'
			}))}
		status: {type: (GraphQLInt)}


		})
	})


