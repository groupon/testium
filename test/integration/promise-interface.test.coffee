injectBrowser = require '../../mocha'
assert = require 'assertive-as-promised'

describe 'driverType: promiseChain', ->
  before injectBrowser driverType: 'promiseChain'

  before ->
    @browser
      .navigateTo '/'
      .assertStatusCode 200

  it 'can open a page and check the title', ->
    assert.equal 'Test Title', @browser.title()
