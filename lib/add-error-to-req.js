'use strict'

// default error formatted from express-validator
// NOTE: if we ever override the express-validator middleware
// formatter, use the same fn here.
const errorFormatter = function(param, msg, value) {
  return {
    param : param,
    msg   : msg,
    value : value
  }
}

// extracted from express_validator#errorHandler internal fn
const addToReq = function(req, param, msg, value) {
  var error = errorFormatter(param, msg, value)

  // same internal collection that stores express-validator errors
  if (req._validationErrors === undefined) {
    req._validationErrors = []
  }
  req._validationErrors.push(error)

  if (req.onErrorCallback) {
    req.onErrorCallback(msg)
  }
  return this
}

exports.errorFormatter = errorFormatter
exports.addToReq = addToReq
