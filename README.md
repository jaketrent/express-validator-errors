## express-validator-errors

Error json serializer for consistent errors when using [express-validator](https://github.com/ctavan/express-validator)

Combines errors from different sources:
- errors in serializer function argument
- errors in req.body.errors
- errors in req.validationErrors()

### Usage Examples

#### Data Validation

`errors.addToReq` - add your own errors to to express-validator's `_validationErrors` without mixing in new validators
`errors.serialize` - outputs all known validation errors

```js
var errors = require('express-validator-errors')

var isValid = function (req) {
  if (!req.body.objects)
    errors.addToReq(req, 'objects', 'Root objects array is required', req.body)

  req.checkBody(['objects', 0, 'title'], 'Title is required').notEmpty()

  return req.validationErrors().length == 0
}

var expressReqHandler = function (req, res) {
  if (isValid(req)) {
    // ... happiness
  } else {
    res.json(400, errors.serialize(req))
  }
}

// example input =>
// { objects: [{}] }

// outputs =>
// { 
//   "errors": [
//     {
//       "param": "objects.0.title",
//       "msg": "Title is required"
//     }
//   ]
// }

```

#### Error Handling

`errors.serialize` - outputs all known validation errors and the specific errors you ask it to output.  Options are:
- Null (in which case, errors on req are serialized)
- Single error
- Array of errors
- Single Error object

```js
var errors = require('express-validator-errors')

var expressReqHandler = function (req, res) {
  doSomethingThatSometimesErrors(function (err, data) {
    if (err) 
      return res.json(500, errors.serialize(new Error('An error occurred'), req(
    
    // ... happiness
  }
}

// example output =>
// { 
//   "errors": [
//     { 
//       "exception": {
//         "message": "An error occurred",
//         "stack": "... file stack trace ..."
//       }
//     }
//   ]
// }
```