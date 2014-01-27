{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'navigation', ->
  before ->
    @browser = getBrowser()

  it 'to absolute url', ->
    @browser.navigateTo 'http://127.0.0.1:4003/'
    @browser.assert.httpStatus 200

  it 'directly', ->
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

  it 'by clicking a link', ->
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

    @browser.click '.link-to-other-page'
    assert.equal '/other-page.html', @browser.getPath()

  it 'by refreshing', ->
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

    @browser.refresh()
    @browser.assert.httpStatus 200

    # No real way to assert this worked

  describe 'waiting for a url', ->
    it 'can work with a string', ->
      @browser.navigateTo '/redirect-after.html'
      @browser.assert.httpStatus 200

      @browser.waitForUrl 'http://127.0.0.1:4445/index.html'

    it 'can work with a regex', ->
      @browser.navigateTo '/redirect-after.html'
      @browser.assert.httpStatus 200

      @browser.waitForUrl /\/index.html/

    it 'can fail', ->
      @browser.navigateTo '/index.html'
      @browser.assert.httpStatus 200

      error = assert.throws => @browser.waitForUrl '/some-random-place.html', 5
      expectedError = 'Timed out (5ms) waiting for url (/some-random-place.html). Last url was: http://127.0.0.1:4445/index.html'
      assert.equal expectedError, error.message

  describe 'waiting for a path', ->
    it 'can work with a string', ->
      @browser.navigateTo '/redirect-after.html'
      @browser.assert.httpStatus 200

      @browser.waitForPath '/index.html'

    it 'can work with a regex', ->
      @browser.navigateTo '/redirect-after.html'
      @browser.assert.httpStatus 200

      @browser.waitForPath /index.html/

