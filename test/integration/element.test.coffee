injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'element', ->
  before injectBrowser()

  before ->
    @browser.navigateTo '/'

  it "can get an element's text", ->
    element = @browser.getElement 'h1'
    text = element.get 'text'
    assert.equal 'Element text was not found', 'Test Page!', text

  it "can get special properties from an element", ->
    # the "checked" property (when it doesn't exist)
    # returns a non-standard response from selenium;
    # let's make sure we can handle it properly
    element = @browser.getElement '#checkbox'
    checked = element.get 'checked'
    assert.equal 'checked is null', null, checked

  it "returns null when the element can not be found", ->
    element = @browser.getElement '.non-existing'
    assert.equal 'Element magically appeared on the page', null, element

  it 'can get several elements', ->
    elements = @browser.getElements '.message'
    count = elements.length
    assert.equal 'Messages were not all found', 3, count

  describe 'elementIsVisible', ->
    it 'fails if element does not exist', ->
      error = assert.throws => @browser.assert.elementIsVisible '.non-existing'
      expectedError = 'Assertion failed: Element not found for selector: .non-existing\n\u001b[39;49;00mExpected \u001b[31mnull\u001b[39m to be truthy'
      assert.equal expectedError, error.message

    it 'fails if element exists, but is not visible', ->
      error = assert.throws => @browser.assert.elementIsVisible '#hidden_thing'
      expectedError = 'Assertion failed: Element should be visible for selector: #hidden_thing\n\u001b[39;49;00mExpected \u001b[31mfalse\u001b[39m to be truthy'
      assert.equal expectedError, error.message

    it 'succeeds if element exists and is visible', ->
      @browser.assert.elementIsVisible 'h1'

  describe 'elementNotVisible', ->
    it 'fails if element does not exist', ->
      error = assert.throws => @browser.assert.elementNotVisible '.non-existing'
      expectedError = 'Assertion failed: Element not found for selector: .non-existing\n\u001b[39;49;00mExpected \u001b[31mnull\u001b[39m to be truthy'
      assert.equal expectedError, error.message

    it 'fails if element exists, but is visible', ->
      error = assert.throws => @browser.assert.elementNotVisible 'h1'
      expectedError = 'Assertion failed: Element should not be visible for selector: h1\n\u001b[39;49;00mExpected \u001b[31mtrue\u001b[39m to be falsey'
      assert.equal expectedError, error.message

    it 'succeeds if element exists and is not visible', ->
      @browser.assert.elementNotVisible '#hidden_thing'

  describe 'elementExists', ->
    it 'fails if element does not exist', ->
      error = assert.throws => @browser.assert.elementExists '.non-existing'
      expectedError = 'Assertion failed: Element not found for selector: .non-existing\n\u001b[39;49;00mExpected \u001b[31mnull\u001b[39m to be truthy'
      assert.equal expectedError, error.message

    it 'succeeds if element exists', ->
      @browser.assert.elementExists 'h1'

  describe 'elementDoesntExist', ->
    it 'succeeds if element does not exist', ->
      @browser.assert.elementDoesntExist '.non-existing'

    it 'fails if element exists', ->
      error = assert.throws => @browser.assert.elementDoesntExist 'h1'
      expectedError = 'Assertion failed: Element found for selector: h1\n\u001b[39;49;00mExpected \u001b[31mElement\u001b[39m to be falsey'
      assert.equal expectedError, error.message

  describe 'elementHasText', ->
    it 'finds and returns a single element', ->
      element = @browser.assert.elementHasText('.only', 'only one here')
      assert.equal "resolve the element's class", 'only', element.get('class')

    it 'finds an element with the wrong text', ->
      error = assert.throws =>
        @browser.assert.elementHasText('.only', 'the wrong text')

      expected = 'Assertion failed: elementHasText: .only\n\u001b[39;49;00minclude expected needle to be found in haystack\n- needle: \"the wrong text\"\nhaystack: \"only one here\"'
      assert.equal expected, error.message

    it 'finds no elements', ->
      error = assert.throws =>
        @browser.assert.elementHasText('.does-not-exist', 'some text')

      assert.equal 'Element not found for selector: .does-not-exist', error.message

    it 'finds many elements', ->
      error = assert.throws =>
        @browser.assert.elementHasText '.message', 'some text'

      assert.equal 'assertion needs a unique selector!\n.message has 3 hits in the page', error.message

    it 'succeeds with empty string', ->
      @browser.assert.elementHasText '#blank-input', ''

  describe 'elementLacksText', ->
    it 'asserts an element lacks some text, and returns the element', ->
      element = @browser.assert.elementLacksText '.only', 'this text not present'
      assert.equal "resolve the element's class", 'only', element.get('class')

    it 'finds an element incorrectly having some text', ->
      error = assert.throws =>
        @browser.assert.elementLacksText('.only', 'only')

      expected = 'Assertion failed: elementLacksText: .only\n\u001b[39;49;00mnotInclude expected needle not to be found in haystack\n- needle: \"only\"\nhaystack: \"only one here\"'
      assert.equal expected, error.message

  describe 'elementHasValue', ->
    it 'finds and returns a single element', ->
      element = @browser.assert.elementHasValue('#text-input', 'initialvalue')
      assert.equal "resolve the element's id", 'text-input', element.get('id')

    it 'succeeds with empty string', ->
      @browser.assert.elementHasValue '#blank-input', ''

  describe 'elementLacksValue', ->
    it 'asserts an element lacks some value, and returns the element', ->
      element = @browser.assert.elementLacksValue '#text-input', 'this text not present'
      assert.equal "resolve the element's id", 'text-input', element.get('id')

    it 'finds an element incorrectly having some text', ->
      error = assert.throws =>
        @browser.assert.elementLacksValue('#text-input', 'initialvalue')

      expected = 'Assertion failed: elementLacksValue: #text-input\n\u001b[39;49;00mnotInclude expected needle not to be found in haystack\n- needle: \"initialvalue\"\nhaystack: \"initialvalue\"'
      assert.equal expected, error.message

  describe 'waitForElementExist', ->
    before ->
      @browser.navigateTo '/dynamic.html'

    it 'finds an element after waiting', ->
      @browser.assert.elementNotVisible('.load_later')
      @browser.waitForElementExist('.load_later')

    it 'finds a hidden element', ->
      @browser.assert.elementNotVisible('.load_never')
      @browser.waitForElementExist('.load_never')

    it 'fails to find an element that never exists', ->
      error = assert.throws =>
        @browser.waitForElementExist('.does-not-exist', 10)
      assert.equal 'Timeout (10ms) waiting for element (.does-not-exist) to exist in page.', error.message

  describe 'waitForElementVisible', ->
    before ->
      @browser.navigateTo '/dynamic.html'

    it 'finds an element after waiting', ->
      @browser.assert.elementNotVisible('.load_later')
      @browser.waitForElementVisible('.load_later')

    it 'fails to find a visible element within the timeout', ->
      error = assert.throws =>
        @browser.waitForElementVisible('.load_never', 10)
      assert.equal 'Timeout (10ms) waiting for element (.load_never) to be visible.', error.message

    it 'fails to find an element that never exists', ->
      error = assert.throws =>
        @browser.waitForElementVisible('.does-not-exist', 10)
      assert.equal 'Timeout (10ms) waiting for element (.does-not-exist) to be visible.', error.message

  describe 'waitForElementNotVisible', ->
    before ->
      @browser.navigateTo '/dynamic.html'

    it 'does not find an existing element after waiting for it to disappear', ->
      @browser.assert.elementIsVisible('.hide_later')
      @browser.waitForElementNotVisible('.hide_later')

    it 'fails to find a not-visible element within the timeout', ->
      error = assert.throws =>
        @browser.waitForElementNotVisible('.hide_never', 10)
      assert.equal 'Timeout (10ms) waiting for element (.hide_never) to not be visible.', error.message

    it 'fails to find an element that never exists', ->
      error = assert.throws =>
        @browser.waitForElementNotVisible('.does-not-exist', 10)
      assert.equal 'Timeout (10ms) waiting for element (.does-not-exist) to not be visible.', error.message

  describe '#getElement', ->
    before ->
      @browser.navigateTo '/'

    beforeEach ->
      @element = @browser.getElement 'body'

    it 'fails if selector is undefined', ->
      assert.throws ->
        @element.getElement(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        @element.getElement(->)

    it 'succeeds if selector is a String', ->
      @element.getElement '.message'

    it 'return null if not found an element on the message element', ->
      messageElement = @browser.getElement '.message'
      element = messageElement.getElement '.message'
      assert.falsey element

  describe '#getElements', ->
    before ->
      @browser.navigateTo '/'

    beforeEach ->
      @element = @browser.getElement 'body'

    it 'fails if selector is undefined', ->
      assert.throws ->
        @element.getElements(undefined)

    it 'fails if selector is not a String', ->
      assert.throws ->
        @element.getElements(->)

    it 'succeeds if selector is a String', ->
      @element.getElements('.message')

    it 'return empty array if not found an element on the message element', ->
      messageElement = @browser.getElement '.message'
      elements = messageElement.getElements '.message'
      assert.equal 0, elements.length
