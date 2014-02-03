{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'console logs', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

  it 'can be retrieved', ->
    logs = @browser.getConsoleLogs()
    assert.equal 4, logs.length

    ### broken in phantomjs

    logs = @browser.getConsoleLogs()
    assert.equal 0, logs.length

    @browser.click '#log-button'

    logs = @browser.getConsoleLogs()
    assert.equal 4, logs.length
    ###

