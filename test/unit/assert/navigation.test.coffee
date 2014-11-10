NavigationMixin = require '../../../lib/assert/navigation'
assert = require 'assertive'
{extend} = require 'lodash'

describe 'assert.navigations', ->
  context =
    browser:
      getStatusCode: -> 200
  extend context, NavigationMixin

  it 'fails if expectedStatus is undefined', ->
    assert.throws ->
      context.httpStatus(undefined)

  it 'fails if expectedStatus is not a number', ->
    assert.throws ->
      context.httpStatus('200')

  it 'succeeds if expectedStatus is a number', ->
    context.httpStatus(200)
