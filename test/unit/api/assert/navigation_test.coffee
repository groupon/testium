Navigation = require '../../../../lib/api/assert/navigation'
assert = require 'assertive'

describe 'assert.navigations', ->
  api =
    getStatusCode: -> 200
  httpStatus = Navigation(api).httpStatus

  it 'fails if expectedStatus is undefined', ->
    assert.throws ->
      httpStatus(undefined)

  it 'fails if expectedStatus is not a number', ->
    assert.throws ->
      httpStatus('200')

  it 'succeeds if expectedStatus is a number', ->
    httpStatus(200)

