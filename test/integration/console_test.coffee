{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'console logs', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

  it 'can all be retrieved', ->
    logs = @browser.getConsoleLogs()
    assert.equal 4, logs.length

    # incomplete WebDriver implementations
    # don't clear the log buffer
    if @browser.capabilities.testium.consoleLogs == 'all'
      logs = @browser.getConsoleLogs()
      assert.equal 0, logs.length

      @browser.click '#log-button'

      logs = @browser.getConsoleLogs()
      assert.equal 4, logs.length

