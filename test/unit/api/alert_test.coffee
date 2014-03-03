Alert = require '../../../lib/api/alert'
assert = require 'assertive'

describe 'alert', ->
  driver =
    typeAlert: ->
  alert = Alert(driver)

  describe '#type', ->
    it 'fails if text is undefined', ->
      assert.throws ->
        alert.type(undefined)

    it 'fails if text is not a String', ->
      assert.throws ->
        alert.type(->)

    it 'succeeds if text is a String', ->
      alert.type 'some text'

