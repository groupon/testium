ElementMixin = require '../../../lib/browser/element'
assert = require 'assertive'
{extend} = require 'lodash'

describe 'element', ->
  describe '#getElement', ->
    driver =
      getElement: ->
    element = extend {driver}, ElementMixin

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
    element = extend {driver}, ElementMixin

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.getElements(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.getElements(->)

    it 'succeeds if selector is a String', ->
      element.getElements('.box')

  describe '#waitForElementVisible', ->
    driver =
      setElementTimeout: ->
      getElement: -> {isVisible: -> true}
    element = extend {driver}, ElementMixin

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.waitForElementVisible(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.waitForElementVisible(->)

    it 'succeeds if selector is a String', ->
      element.waitForElementVisible('.box')

  describe '#waitForElementNotVisible', ->
    driver =
      setElementTimeout: ->
      getElement: -> {isVisible: -> false}
    element = extend {driver}, ElementMixin

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.waitForElementNotVisible(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.waitForElementNotVisible(->)

    it 'succeeds if selector is a String', ->
      element.waitForElementNotVisible('.box')

  describe '#click', ->
    driver =
      getElement: -> {click: ->}
    element = extend {driver}, ElementMixin

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.click(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.click(->)

    it 'succeeds if selector is a String', ->
      element.click('.box')

