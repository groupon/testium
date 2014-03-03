Element = require '../../../lib/api/element'
assert = require 'assertive'

describe 'element', ->
  describe '#getElement', ->
    driver =
      getElement: ->
    element = Element(driver)

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.getElement(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.getElement(->)

    it 'succeeds if selector is a String', ->
      element.getElement('.box')

  describe '#getElements', ->
    driver =
      getElements: ->
    element = Element(driver)

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.getElements(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.getElements(->)

    it 'succeeds if selector is a String', ->
      element.getElements('.box')

  describe '#waitForElement', ->
    driver =
      setElementTimeout: ->
      getElement: -> {isVisible: -> true}
    element = Element(driver)

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.waitForElement(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.waitForElement(->)

    it 'succeeds if selector is a String', ->
      element.waitForElement('.box')

  describe '#click', ->
    driver =
      getElement: -> {click: ->}
    element = Element(driver)

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.click(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.click(->)

    it 'succeeds if selector is a String', ->
      element.click('.box')

