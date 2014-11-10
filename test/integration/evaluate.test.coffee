injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'evaluate', ->
  before injectBrowser()

  before ->
    @browser.navigateTo '/'

  it 'runs JavaScript passed as a String', ->
    value = @browser.evaluate 'return 3;'
    assert.equal 3, value

  it 'runs JavaScript passed as a Function', ->
    assert.equal 6, @browser.evaluate -> 6

  it 'runs JavaScript passed as a Function with optional prepended args', ->
    assert.equal 18, @browser.evaluate 3, 6, (a, b) -> a * b
