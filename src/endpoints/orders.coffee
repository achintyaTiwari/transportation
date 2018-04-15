express = require 'express'
router = express.Router()
request = require 'request-promise'

router.param 'orderId', (req, res, next, id)->
  Q().then(->
    db.models.Order.findOne({_id: id}).deepPopulate(['user'])
  ).then((order)->
    if not order
      res.notFound()
    else
      req.order = order
      next()
  ).catch(next).done()

###
@api {GET} /orders List
@apiName List
@apiGroup Orders

@apiHeader {String} Authorization Session Token

@apiParam {String} operator_id
@apiParam {String} schedule_id
@apiParam {String} trip_id
@apiParam {String} type
@apiParam {String=payment_method, type} group_by

@apiSuccess {Boolean} status true
@apiSuccess {Array} data Array of order objects
###
router.get '/', (req, res, next)->
  Q().then(->
    if not req.query.operator_id then return Q.reject(ERROR.InvalidRequest)

    query = {
      operator: req.query.operator_id
      created_at: { # FIXME: add date filtering
        $gte: moment().startOf('day')
        $lte: moment().endOf('day')
      }
    }

    if req.query.schedule_id then query.schedule = req.query.schedule_id
    if req.query.trip_id then query.trip = req.query.trip_id
    if req.query.type then query.type = req.query.type.toUpperCase()

    db.models.Order.find(query).deepPopulate(['user'])
  ).then((orders)->
    if req.query.group_by
      orders = _.groupBy(orders, (order)->
        if _.isObject(order.payment) and order.payment.method
          order.payment.method.toLowerCase()
        else
          'unknown'
      )
    res.success(orders)
  ).catch(next).done()

###
@api {GET} /orders/export/ksrtc Export
@apiName Export
@apiGroup Orders

@apiHeader {String} Authorization Session Token

@apiParam {String} abstract_id

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed order object
###
router.get '/export/ksrtc', (req, res, next)->
  Q().then(->
    query = {
      abstract_id: req.query.abstract_id
    }
    db.models.Order.find(query).deepPopulate(['user'])
  ).catch(next).done()

###
@api {GET} /orders/:orderId Get
@apiName Get
@apiGroup Orders

@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Detailed order object
###
router.get '/:orderId', (req, res, next)->
  res.success(req.order)

###
@api {POST} /orders Create
@apiName Create
@apiGroup Orders

@apiHeader {String} Authorization Session Token

@apiParam {String} operator_id
@apiParam {String} schedule_id
@apiParam {String} trip_id
@apiParam {String=pass,passenger_ticket,online_booking} type

@apiParam (Type: pass) {String} product_id
@apiParam (Type: pass) {String} user_id
@apiParam (Type: pass) {Number} amount

@apiParam (Type: passenger_ticket) {String} user_id
@apiParam (Type: passenger_ticket) {String} from
@apiParam (Type: passenger_ticket) {String} to
@apiParam (Type: passenger_ticket) {Number} amount
@apiParam (Type: passenger_ticket) {Number} adults
@apiParam (Type: passenger_ticket) {Number} children

@apiParam (Type: concession_ticket) {String} user_id
@apiParam (Type: concession_ticket) {String} concession_id
@apiParam (Type: concession_ticket) {String} from
@apiParam (Type: concession_ticket) {String} to
@apiParam (Type: concession_ticket) {Number} amount
@apiParam (Type: concession_ticket) {Number} adults
@apiParam (Type: concession_ticket) {Number} children

@apiParam (Type: online_booking) {String} first_name
@apiParam (Type: online_booking) {String} last_name
@apiParam (Type: online_booking) {String} seat_number
@apiParam (Type: online_booking) {String} mobile_number
@apiParam (Type: online_booking) {String} from
@apiParam (Type: online_booking) {String} to

@apiSuccess {Boolean} status true
@apiSuccess {Object} data new order object
@apiError (Error400) {String} InvalidRequest
@apiError (Error400) {String} MissingOrderType
@apiError (Error400) {String} ProductNotFound

###
router.post '/', (req, res, next)->
  Q().then(->
    if not hasRequiredParams(req.body, ['operator_id', 'type']) then return Q.reject(ERROR.RequiredParamsMissing) #CODE CHANGED BY ACHINTYA

    product = null

    switch req.body.type.toLowerCase()
      when 'pass'
        product = db.models.Product.findOne({ _id: req.body.product_id, status: CONST.STATUS.ACTIVE })
      when 'passenger_ticket'
        if not hasRequiredParams(req.body, ['from', 'to'])
          return Q.reject(ERROR.InvalidRequest)

        product = {
          journey: {
            from: req.body.from
            to: req.body.to
            adults: req.body.adults
            children: req.body.children
          }
        }
      when 'online_booking'
        if not hasRequiredParams(req.body, ['from', 'to', 'seat_number'])
          return Q.reject(ERROR.InvalidRequest)

        product = {
          first_name: req.body.first_name
          last_name: req.body.last_name
          seat_number: req.body.seat_number
          mobile_number: req.body.mobile_number # TODO: may be create user profile automatically?
          journey: {
            from: req.body.from
            to: req.body.to
          }
        }
      else return Q.reject(ERROR.MissingOrderType)

    [req.body.type.toLowerCase(), product]
  ).spread((type, product)->
    if type is 'pass' and not product then return Q.reject(ERROR.ProductNotFound)

    active_waybill = null
    order = new db.models.Order({
      operator: req.body.operator_id
      user: req.body.user_id or 'UNKNOWN'
      trip: req.body.trip_id
      schedule: req.body.schedule_id
      amount: req.body.amount
      type: req.body.type
    })

    if type is 'pass'
      order.product = product.toObject()
      order.validity = product.validity
      order.validity_type = product.validity_type
    else
      order.product = product

    if type is 'online_booking'
      order.status = CONST.ORDER_STATUS.ACTIVE
      # TODO: at any given time there should be only one active waybill
      active_waybill = db.models.Assignment.findOne({
        schedules: order.schedule
        status: CONST.STATUS.ACTIVE
      }).deepPopulate(['device'])

    [ order.save(), active_waybill ]
  ).spread((order, active_waybill)->
    if active_waybill isnt null
      modules.push.send(active_waybill.device.token, {
        action: "TRIPSHEET_UPDATED"
        schedule_id: req.body.schedule_id
        order_id: order.id
      })
    res.success(order, HTTP_STATUS_CODES.CREATED)
  ).catch(next).done()

###
@api {POST} /orders/:orderId/payment Update payment status
@apiName UpdatePayment
@apiGroup Orders

@apiHeader {String} Authorization Session Token

@apiParam {Object} payment payment response object from the gateway

@apiSuccess {Boolean} status true
@apiSuccess {Object} data Updated order object
@apiError (Error400) {String} PaymentUpdateNotAllowed
@apiError (Error400) {String} InvalidPaymentObject
@apiError (Error400) {String} StatusCodeError
###
router.post '/:orderId/payment', (req, res, next)->
  order = req.order
  Q().then(->
    if order.status isnt CONST.ORDER_STATUS.CREATED then return Q.reject(ERROR.PaymentUpdateNotAllowed)

    if not _.isObject(req.body.payment) or not _.has(req.body.payment, 'id')
      return Q.reject(ERROR.InvalidPaymentObject)
    order.payment = req.body.payment
    order.status = CONST.ORDER_STATUS.PAYMENT_APPROVED
    # TODO: move the payment capturing to its own service providers specific module
    [order.save()
      request
        .post("#{ config.razorpay.base_url }payments/#{order.payment.id}/capture")
        .auth(config.razorpay.key_id, config.razorpay.key_secret)
        .form({amount: order.amount})
    ]
  ).spread((order, capture_response)->
    _.extend(order.payment, {
      capture_response: capture_response
      captured_at: moment()
    })
    order.status = CONST.ORDER_STATUS.ACTIVE
    order.save()
  ).then((order)->
    res.success(order)
  ).catch(next
    
    #console.error err
    #switch err.name
    # when 'StatusCodeError'
    #    _.extend(order.payment, {
    #      capture_response: err.response.body
    #      captured_at: moment()
    #    })
    #    order.status = CONST.ORDER_STATUS.PAYMENT_FAILED
    #    order.save()
    #    res.badRequest(error.statusErrorCode())
    #  else next()
    
  ).done()

###
@api {DELETE} /orders/:orderId Delete
@apiName Delete
@apiGroup Orders

@apiPermission Admin
@apiHeader {String} Authorization Session Token

@apiSuccess {Boolean} status true
###
router.delete '/:orderId', (req, res, next)->
  Q(req.order).then((order)->
    order.remove()
  ).then(->
    res.success()
  ).catch(next).done()

module.exports = router