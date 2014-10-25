InputMixin = require '../../../lib/browser/input'
assert = require 'assertive'
{extend, noop} = require 'lodash'

describe 'input api', ->
  describe '#type', ->
    element =
      type: ->
    driver =
      getElement: -> element
    input = extend {driver}, InputMixin
    selector = '.box'
    keys = 'puppies'

    it 'fails if selector is undefined', ->
      assert.throws ->
        input.type(undefined, keys)

    it 'fails if selector is not a String', ->
      assert.throws ->
        input.type(noop, keys)

    it 'fails if keys is not defined', ->
      assert.throws ->
        input.type(selector)

    it 'succeeds if all conditions are met', ->
      input.type(selector, keys)

  describe '#clear', ->
    element =
      clear: ->
    driver =
      getElement: -> element
    input = extend {driver}, InputMixin
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        input.clear(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        input.clear(noop)

    it 'succeeds if all conditions are met', ->
      input.clear(selector)

  describe '#clearAndType', ->
    element =
      clear: ->
      type: ->
    driver =
      getElement: -> element
    input = extend {driver}, InputMixin
    selector = '.box'
    keys = 'puppies'

    it 'fails if selector is undefined', ->
      assert.throws ->
        input.clearAndType(undefined, keys)

    it 'fails if selector is not a String', ->
      assert.throws ->
        input.clearAndType(noop, keys)

    it 'fails if keys is not defined', ->
      assert.throws ->
        input.clearAndType(selector)

    it 'succeeds if all conditions are met', ->
      input.clearAndType(selector, keys)

