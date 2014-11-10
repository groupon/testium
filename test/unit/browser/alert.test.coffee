AlertMixin = require '../../../lib/browser/alert'
assert = require 'assertive'
{extend} = require 'lodash'

describe 'alert', ->
  driver =
    typeAlert: ->
  alert = extend {driver}, AlertMixin

  describe '#typeAlert', ->
    it 'fails if text is undefined', ->
      assert.throws ->
        alert.typeAlert(undefined)

    it 'fails if text is not a String', ->
      assert.throws ->
        alert.typeAlert(->)

    it 'succeeds if text is a String', ->
      alert.typeAlert 'some text'
