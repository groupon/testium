Element = require '../../../lib/api/assert/element'
assert = require 'assertive'

describe 'assert', ->
  describe '#elementHas', ->
    driver =
      getElements: -> [ get: -> 'something' ]
    element = Element(driver)
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

      it 'suceeds if all conditions are met', ->
        element.elementHasText(selector, text)

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

      it 'suceeds if all conditions are met', ->
        element.elementHasValue(selector, text)

  describe '#elementLacks', ->
    driver =
      getElements: -> [
        get: -> 'else'
      ]
    element = Element(driver)
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

      it 'suceeds if all conditions are met', ->
        element.elementLacksText(selector, text)

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

      it 'suceeds if all conditions are met', ->
        element.elementLacksValue(selector, text)

  describe '#elementIsVisible', ->
    driver =
      getElement: -> { isVisible: -> true }
    element = Element(driver)
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementIsVisible(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementIsVisible(->)

    it 'succeeds if all conditions are met', ->
      element.elementIsVisible('.box')

  describe '#elementNotVisible', ->
    driver =
      getElement: -> { isVisible: -> false }
    element = Element(driver)
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementNotVisible(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementNotVisible(->)

    it 'succeeds if all conditions are met', ->
      element.elementNotVisible('.box')

  describe '#elementExists', ->
    driver =
      getElement: -> {}
    element = Element(driver)
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementExists(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementExists(->)

    it 'succeeds if all conditions are met', ->
      element.elementExists('.box')

  describe '#elementExists', ->
    driver =
      getElement: -> null
    element = Element(driver)
    selector = '.box'

    it 'fails if selector is undefined', ->
      assert.throws ->
        element.elementDoesntExist(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        element.elementDoesntExist(->)

    it 'succeeds if all conditions are met', ->
      element.elementDoesntExist('.box')

