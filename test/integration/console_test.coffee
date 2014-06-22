{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'console logs', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

  # Each browser fails to implement the WebDriver spec
  # for console.logs differently.
  # Use at your own risk.
  it 'can all be retrieved', ->
    browser = @browser.capabilities.browserName

    switch browser
      when 'firefox'
        # firefox ignores this entirely
        # CoffeeScript errors on empty when blocks
        assert.equal 1, 1

      when 'chrome'
        logs = @browser.getConsoleLogs()
        assert.truthy 'console.logs length', logs.length > 0

        logs = @browser.getConsoleLogs()
        assert.equal 0, logs.length

        @browser.click '#log-button'

        logs = @browser.getConsoleLogs()
        assert.truthy 'console.logs length', logs.length > 0

      else
        logs = @browser.getConsoleLogs()
        assert.truthy 'console.logs length', logs.length > 0

