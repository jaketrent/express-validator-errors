var req = require('./lib/error-serializer')
var serialize = require('./lib/serialize-error')

exports.serialize = serialize
exports.errorFormatter = req.errorFormatter
exports.addToReq = req.addToReq
