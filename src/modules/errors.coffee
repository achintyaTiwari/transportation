#Error Handling MiddleWare
#Handling  Endpoints error



module.exports = {
  NotAllowed:
    name    : 'NOT_ALLOWED'
    message : 'Authentication invalid'
  RequiredParamsMissing:
    name    : 'MISSING_PARAMS'
    message : 'Required Parameters are missing'
  InvalidRequest:
    name    : 'INVALID_REQUEST'
    message : 'Parameters missing or invalid'
  InvalidOperatorId:
    name    : 'INVALID_OPERATOR_ID'
    message : 'Operator not found or active'
  EntityExists:
    name    : 'ENTITY_EXISTS'
    message : 'Duplicate entry not allowed'
  EntityNotFound:
    name    : 'ENTITY_NOT_FOUND'
    message : 'Specified entity is not found'
  InvalidToken:
    name    : 'INVALID_TOKEN'
    message : 'The Token is invalid'
  MissingPayload:
    name    : 'MISSING_PAYLOAD'
    message : 'The payload is missing'
  ValidationError:
    name    : 'VALIDATION_ERROR'
    message : 'Input value is not valid'
  OngoingAssignmentFound:
    name    : 'ONGOING_ASSIGNMENT_FOUND'
    message : 'The assignment is found to be ongoing'
  OperatorNotActive:
    name    : 'OPERATOR_NOT_ACTIVE'
    message : 'Operator is not active'
  OperatorNotFound:
    name    : 'OPERATOR_NOT_FOUND'
    message : 'Operator not found'
  ConductorNotFound:
    name    : 'CONDUCTOR_NOT_FOUND'
    message : 'Conductor Not Found'
  ScheduleMismatch:
    name    : 'SCHEDULE_MISMATCH'
    message : 'Schedule mismatching'
  DeviceNotFound:
    name    : 'DEVICE_NOT_FOUND'
    message : 'Device not found'
  MongoError:
    name    : 'MONGO_ERROR'
    message : 'Error in Database'
  VehicleNotFound:
    name    : 'VEHICLE_NOT_FOUND'
    message : 'Vehicle Not Found'
  MissingCommuterId:
    name    : 'MISSING_COMMUTER_ID'
    message : 'Missing Commuter ID'
  OrderNotFound:
    name    : 'ORDER_NOT_FOUND'
    message : 'Order Not Found'
  TripNotFound:
    name    : 'TRIP_NOT_FOUND'
    message : 'Trip Not Found'
  OngoingJourneyFound:
    name    : 'ONGOING_JOURNEY_FOUND'
    message : 'Ongoing Journey Found'
  JourneyAlreadyEnded:
    name    : 'JOURNEY_ALREADY_ENDED'
    message : 'Journey has already Ended'
  OrderNotActive:
    name    : 'ORDER_NOT_ACTIVE'
    message : 'Order is not Active'
  MissingOrderType:
    name    : 'MISSING_ORDER_TYPE'
    message : 'Order Type is missing'
  ProductNotFound:
    name    : 'PRODUCT_NOT_FOUND'
    message : 'Product not found'
  PaymentUpdateNotAllowed:
    name    : 'PAYMENT_UPDATE_NOT_ALLOWED'
    message : 'Payment Update Not Allowed'
  InvalidPaymentObject:
    name    : 'INVALID_PAYMENT_OBJECT'
    message : 'Invalid Payment Object'
  StatusErrorCode:
    name    : 'STATUS_ERROR_CODE'
    message : 'Status error code'
   MissingValidityType:
    name    : 'MISSING_VALIDITY_TYPE'
    message : 'Missing Validity Type'
  ServiceTypeNotFound:
    name    : 'SERVICE_TYPE_NOT_FOUND'
    message : 'Service Type not found'
  RouteNotFound:
    name    : 'ROUTE_NOT_FOUND'
    message : 'Route not found'
  OngoingTripFound:
    name    : 'ONGOING_TRIP_FOUND'
    message : 'Ongoing trip found'
  AssignmentNotFound:
    name    : 'ASSIGNMENT_NOT_FOUND'
    message : 'Assignment is not found'
  ScheduleNotFound:
    name    : 'SCHEDULE_NOT_FOUND'
    message : 'Schedule is not found'
  TripAlreadyEnded:
    name    : 'TRIP_ALREADY_ENDDED'
    message : 'Trip has already ended'
  MissingUserType:
    name    : 'MISSING_USER_TYPE'
    message : 'UserType is missing'
  MissingParams:
    name    : 'MISSING_PARAMS'
    message : 'Some parameters are missing'
  MissingPassword:
    name    : 'MISSING_PASSWORD'
    message : 'Password is missing'
  MissingOTP:
    name    : 'MISSING_OTP'
    message : 'OTP is missing'
  InvalidUsernameFormat:
    name    : 'INVALID_USERNAME_FORMAT'
    message : 'The given usename format is invalid'
  DepotNotFound:
    name    : 'DEPOT_NOT_FOUND'
    message : 'Requested Depot is not found'
  DepotNotActive:
    name    : 'DEPOT_NOT_ACTIVE'
    message : 'Requested Depot is not active'
  SessionTokenNotFound:
    name    : 'SESSION_TOKEN_NOT_FOUND'
    message : 'Session Token cannot be found'
  SessionTokenInvalid:
    name    : 'SESSION_TOKEN_INVALID'
    message : 'Session Token is invalid'
  UserNotAuthorized:
    name    : 'USER_NOT_AUTHORIZED'
    message : 'User not Authorised'

}



