{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'evaluate', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/'

  it 'throws an error when passing bad arguments', ->
    explanation = 'evaluate(clientFunction) - requires clientFunction'
    err = assert.throws => @browser.evaluate()
    assert.include explanation, err.message

  it 'runs JavaScript passed as a String', ->
    value = @browser.evaluate 'return 3;'
    assert.equal 3, value

  it 'runs JavaScript passed as a Function', ->
    assert.equal 6, @browser.evaluate -> 6

  it 'runs JavaScript passed as a Function with optional prepended args', ->
    assert.equal 18, @browser.evaluate 3, 6, (a, b) -> a * b
