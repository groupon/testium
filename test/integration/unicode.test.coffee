injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'unicode support', ->
  before injectBrowser()

  before ->
    @browser.navigateTo '/'

  it "multibyte unicode can pass through and back from WebDriver", ->
    multibyteText = "日本語 text"
    element = @browser.getElement '#blank-input'
    element.type multibyteText
    result = element.get('value')
    assert.equal result, multibyteText

