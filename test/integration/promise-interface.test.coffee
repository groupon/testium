injectBrowser = require '../../mocha'
assert = require 'assertive-as-promised'

describe 'driverType: promiseChain', ->
  before injectBrowser driverType: 'promiseChain'

  before ->
    @browser
      .navigateTo '/other-page.html' # dummy load to fake priming
      .navigateTo '/'

  it 'can open a page and check the title', ->
    assert.equal 'Test Title', @browser.title()
