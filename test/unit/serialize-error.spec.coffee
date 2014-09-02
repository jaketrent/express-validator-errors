should = require 'should'

path = require '../util/path'
serialize = require(path.toApp('serialize-error'))

describe 'error-serializer', ->

  it 'no errors, no return', ->
    should.not.exist serialize()

  it 'no errors, but req.body.errors, return req.body.errors', ->
    req =
      body:
        errors: [{ thisIs: 'something' }]
    serialize(null, req).should.eql req.body.errors

  it 'takes req as first parameter, still returns nothing if req has no errors', ->
    req =
      body: {}
      validationErrors: ->
    should.not.exist serialize(req)

  it 'formats errors as an array', ->
    actual = serialize({})
    Array.isArray(actual.errors).should.be.true
    actual.errors.length.should.eql 1

  it 'adds errors to errors array', ->
    err1 = { thisIs: 'something' }
    err2 = { another: 'error' }
    expected =
      errors: [err1, err2]
    serialize([err1, err2]).should.eql expected

  it 'adds errors to existing errors in req.body.errors', ->
    err1 = { thisIs: 'something' }
    err2 = { another: 'error' }
    expected =
      errors: [err1, err2]
    req =
      body:
        errors: [err2]
    serialize([err1], req).should.eql expected

  it 'takes a single error, adds to req.body.errors', ->
    err1 = { thisIs: 'something' }
    err2 = { another: 'error' }
    expected =
      errors: [err1, err2]
    req =
      body:
        errors: [err2]
    serialize(err1, req).should.eql expected

  describe 'Exception Formatting', ->

    it 'shows the error message', ->
      e = new Error('some such explosion in the bowels of the app')
      serialize(e).errors[0].msg.should.eql e.message

    it 'shows the error stack trace', ->
      e = new Error('some such explosion in the bowels of the app')
      serialize(e).errors[0].should.have.property 'stack'
      serialize(e).errors[0].stack.should.not.be.null

    it 'shows the other properties of the error', ->
      errName = 'SpecialError'
      specialVal = 'apiinfo'

      SpecialError = (msg, special) ->
        Error.captureStackTrace(this, arguments.callee)
        @message = msg
        @name = errName
        @special = special
      SpecialError.prototype = Object.create(Error.prototype)

      e = new SpecialError('some such explosion in the bowels of the app', specialVal)
      serializeed = serialize(e)

      serializeed.errors[0].name.should.eql errName
      serializeed.errors[0].special.should.eql specialVal

    it 'has a param name of "server-error"', ->
      e = new Error('some such explosion in the bowels of the app')
      # TODO: adjust to 'id' in future versions -- validator portions should be
      # changeable via the express-validator serializer object
      serialize(e).errors[0].param.should.eql 'server-error'

  describe 'Validation Errors', ->

    it 'uses req.validationErrors() as potentially the only errors', ->
      err1 = { thisIs: 'something' }
      err2 = { another: 'error' }
      expected =
        errors: [err1, err2]
      req =
        validationErrors: ->
          [err1, err2]
      serialize(req).should.eql expected

    it 'adds req.validationErrors() to req.errors', ->
      err1 = { thisIs: 'something' }
      err2 = { another: 'error' }
      expected =
        errors: [err1, err2]
      req =
        body:
          errors: [err2]
        validationErrors: ->
          [err1]
      serialize(req).should.eql expected

    it 'adds req.validationErrors() to errors being passed to the transform', ->
      err1 = { thisIs: 'something' }
      err2 = { another: 'error' }
      expected =
        errors: [err1, err2]
      req =
        validationErrors: ->
          [err2]
      serialize(err1, req).should.eql expected
