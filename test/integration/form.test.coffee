injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'form', ->
  before injectBrowser()

  before ->
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

  it "can get an input's value", ->
    element = @browser.getElement '#text-input'
    value = element.get 'value'
    assert.equal 'Input value was not found', 'initialvalue', value

  it "can clear an input's value", ->
    element = @browser.getElement '#text-input'
    element.clear()
    value = element.get 'value'
    assert.equal 'Input value was not cleared', '', value

  it "can type into an input", ->
    element = @browser.getElement '#text-input'
    element.type 'new stuff'
    value = element.get 'value'
    assert.equal 'Input value was not typed', 'new stuff', value

  it "can replace the input's value", ->
    element = @browser.getElement '#text-input'
    value = element.get 'value'
    assert.notEqual 'Input value is already empty', '', value
    @browser.clearAndType '#text-input', 'new stuff2'
    value = element.get 'value'
    assert.equal 'Input value was not typed', 'new stuff2', value

  it "can get a textarea's value", ->
    element = @browser.getElement '#text-area'
    value = element.get 'value'
    assert.equal 'Input value was not found', 'initialvalue', value

  it "can clear an textarea's value", ->
    element = @browser.getElement '#text-area'
    element.clear()
    value = element.get 'value'
    assert.equal 'Input value was not cleared', '', value

  it "can type into a textarea", ->
    element = @browser.getElement '#text-area'
    element.type 'new stuff'
    value = element.get 'value'
    assert.equal 'Input value was not typed', 'new stuff', value
