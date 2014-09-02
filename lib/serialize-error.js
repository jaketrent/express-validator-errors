'use strict'

var _ = require('underscore')

var isException = function (error) {
  return error && error.constructor && error.constructor.name.match(/.*?Error.*?/)
}

var wrapException = function (error) {
  var exception = {
    param: 'server-error',
    msg: error.message,
    stack: error.stack
  }
  return _.extend({}, exception, _.omit(error, 'message', 'stack'))
}

/**
 * Formats errors consistently for json serialization
 *
 * Combines errors from different sources:
 *
 * - errors in function argument
 * - errors in req.body.errors
 * - errors in req.validationErrors()
 *
 * @param errors {object/array} errors to serialize.  Can be:
 *
 * - Null (in which case, errors on req are serialized)
 * - Single error
 * - Array of errors
 * - Single Error object
 *
 * @param req {object} request object that can include req.body.errors and req.validationErrors()
 * @returns json {object}
 */
module.exports = function (errors, req) {
  var errorsIsReqParam = !req && !!errors && _.isFunction(errors.validationErrors)
  if (errorsIsReqParam) {
    req = errors
    errors = req.validationErrors()
  }

  var reqHasErrors = req && !!req.body && !!req.body.errors
  var reqHasValidationErrors = req && _.isFunction(req.validationErrors)

  if (!errors) return errors || reqHasErrors ? req.body.errors : errors

  var json = {
    errors: []
  }

  var reqErrors = reqHasErrors ? req.body.errors : []
  var reqValidationErrors = (!errorsIsReqParam && reqHasValidationErrors) ? req.validationErrors() : []
  errors = _.flatten([ errors, reqErrors, reqValidationErrors ], true)

  errors.map(function (err) {
    if (isException(err)) err = wrapException(err)
    json.errors.push(err)
  })

  return json
}
