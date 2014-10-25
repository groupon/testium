ElementMixin = require '../../../lib/assert/element'
assert = require 'assertive'
{extend} = require 'lodash'

describe 'assert', ->
  describe '#elementHas', ->
    element =
      driver:
        getElements: -> [ get: -> 'something' ]
    extend element, ElementMixin
    selector = '.box'
    text = 'something'

    describe 'Text', ->
      it 'fails if selector is undefined', ->
        assert.throws ->
          element.elementHasText(undefined, text)

      it 'fails if selector is not a String', ->
        assert.throws ->
          element.elementHasText(999, text)

      it 'fails if text is undefined', ->
        assert.throws ->
          element.elementHasText(selector, undefined)

      it 'returns the element if all conditions are met', ->
        assert.truthy element.elementHasText(selector, text)

    describe 'Value', ->
      it 'fails if selector is undefined', ->
        assert.throws ->
          element.elementHasValue(undefined, text)

      it 'fails if selector is not a String', ->
        assert.throws ->
          element.elementHasValue(999, text)

      it 'fails if text is undefined', ->
        assert.throws ->
          element.elementHasValue(selector, undefined)

      it 'returns the element if all conditions are met', ->
        assert.truthy element.elementHasValue(selector, text)

  describe '#elementLacks', ->
    element =
      driver:
        getElements: -> [ get: -> 'else' ]
    extend element, ElementMixin
    selector = '.box'
    text = 'something'

    describe 'Text', ->
      it 'fails if selector is undefined', ->
        assert.throws ->
          element.elementLacksText(undefined, text)

      it 'fails if selector is not a String', ->
        assert.throws ->
          element.elementLacksText(999, text)

      it 'fails if text is undefined', ->
        assert.throws ->
          element.elementLacksText(selector, undefined)

      it 'returns the element if all conditions are met', ->
        assert.truthy element.elementLacksText(selector, text)

    describe 'Value', ->
      it 'fails if selector is undefined', ->
        assert.throws ->
          element.elementLacksValue(undefined, text)

      it 'fails if selector is not a String', ->
        assert.throws ->
          element.elementLacksValue(999, text)

      it 'fails if text is undefined', ->
        assert.throws ->
          element.elementLacksValue(selector, undefined)

      it 'returns the element if all conditions are met', ->
        assert.truthy element.elementLacksValue(selector, text)

  describe '#elementIsVisible', ->
    element =
      browser:
        getElementWithoutError: -> { isVisible: -> true }
    extend element, ElementMixin
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementIsVisible(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementIsVisible(->)

    it 'returns the element if all conditions are met', ->
      assert.truthy element.elementIsVisible('.box')

  describe '#elementNotVisible', ->
    element =
      browser:
        getElementWithoutError: -> { isVisible: -> false }
    extend element, ElementMixin
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementNotVisible(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementNotVisible(->)

    it 'returns the element if all conditions are met', ->
      assert.truthy element.elementNotVisible('.box')

  describe '#elementExists', ->
    element =
      browser:
        getElementWithoutError: -> {}
    extend element, ElementMixin
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementExists(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementExists(->)

    it 'returns the element if all conditions are met', ->
      assert.truthy element.elementExists('.box')

  describe '#elementDoesntExist', ->
    element =
      browser:
        getElementWithoutError: -> null
    extend element, ElementMixin
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementDoesntExist(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementDoesntExist(->)

    it 'succeeds if all conditions are met', ->
      element.elementDoesntExist('.box')

