{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'form', ->
  before ->
    @browser = getBrowser()
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

  it.only "can replace the input's value", ->
    element = @browser.getElement '#text-input'
    element = @browser.getElement '#text-input'
    element = @browser.getElement '#text-input2'
    element = @browser.getElement '#text-input3'
    element = @browser.getElement '#text-input'

    value = element.get 'value'
    assert.notEqual 'Input value is already empty', '', value
    @browser.clear '#text-input'
    value = element.get 'value'
    #@browser.clear '#text-input'
    #@browser.type '#text-input', 'new stuff2'
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
