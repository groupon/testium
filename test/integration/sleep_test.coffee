{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'sleep', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/'

  it 'sleeps for at least the specified timeout', ->

    timeout = 10

    start = Date.now()
    @browser.sleep timeout
    end = Date.now()

    assert.truthy end - start >= timeout
