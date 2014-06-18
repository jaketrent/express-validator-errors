const path = require('path')

const appDir = process.env.TEST_COVERAGE ? 'lib-cov' : 'lib'

exports.toApp = function (pathFromAppRoot) {
  return path.resolve(appDir, pathFromAppRoot)
}