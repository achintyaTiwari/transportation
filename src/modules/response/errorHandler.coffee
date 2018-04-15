module.exports = (err, req, res, next)->
  console.error err
  console.error err.name
  switch err.name
    when ERROR.NotAllowed.name
        res.forbidden(err.name,err.message)    
    when ERROR.RequiredParamsMissing.name
        res.badRequest(err.name,err.message)
    when ERROR.InvalidOperatorId.name
        res.badRequest(err.name,err.message)
    when ERROR.EntityNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.InvalidRequest.name
        res.badRequest(err.name,err.message)
    when ERROR.InvalidToken.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingPayload.name
        res.badRequest(err.name,err.message)
    when ERROR.ValidationError.name
        res.badRequest(err.name,err.message)
    when ERROR.OngoingAssignmentFound.name
        res.badRequest(err.name,err.message)
    when ERROR.OperatorNotActive.name
        res.badRequest(err.name,err.message)
    when ERROR.OperatorNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.ConductorNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.VehicleNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.ScheduleMismatch.name
        res.badRequest(err.name,err.message)
    when ERROR.DeviceNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingCommuterId.name
        res.badRequest(err.name,err.message)    # Code changed and restored by Achintya (also changed computerid to commuterid)
    when ERROR.OrderNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.OrderNotActive.name
        res.badRequest(err.name,err.message)
    when ERROR.TripNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.OngoingJourneyFound.name
        res.badRequest(err.name,err.message)
    when ERROR.JourneyAlreadyEnded.name
        res.badRequest(err.name,err.message)
    when ERROR.OrderNotActive.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingOrderType.name
        res.badRequest(err.name,err.message)
    when ERROR.ProductNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.OrderNotActive.name
        res.badRequest(err.name,err.message)
    when ERROR.PaymentUpdateNotAllowed.name
        res.badRequest(err.name,err.message)
    when ERROR.InvalidPaymentObject.name
        res.badRequest(err.name,err.message)
    when ERROR.StatusErrorCode.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingValidityType.name
        res.badRequest(err.name,err.message)
    when ERROR.ServiceTypeNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.RouteNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.OngoingTripFound.name
        res.badRequest(err.name,err.message)
    when ERROR.AssignmentNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.ScheduleNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.TripAlreadyEnded.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingUserType.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingParams.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingPassword.name
        res.badRequest(err.name,err.message)
    when ERROR.MissingOTP.name
        res.badRequest(err.name,err.message)
    when ERROR.InvalidUsernameFormat.name
        res.badRequest(err.name,err.message)
    when ERROR.DepotNotFound.name
        res.badRequest(err.name,err.message)
    when ERROR.SessionTokenNotFound.name
        res.unAuthorized(err.name,err.message)
    when ERROR.UserNotAuthorized.name
        res.forbidden(err.name,err.message)
    when 'MongoError'
       switch err.code
          when 11000 then res.badRequest(ERROR.EntityExists.name, ERROR.EntityExists.message)
          when 12501
            modules.email.send(null, "dev@journee.in", "ERROR 12501 in mongoose \n" + err)
            res.serverError()
          else res.serverError()
    else res.serverError()