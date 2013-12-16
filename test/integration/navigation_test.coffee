{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'navigation', ->
  before ->
    @browser = getBrowser()

  it 'directly', ->
    @browser.navigateTo '/'
    assert.equal 'statuscode', 200, @browser.getStatusCode()

  it 'by clicking a link', ->
    @browser.navigateTo '/'
    assert.equal 'statuscode', 200, @browser.getStatusCode()

    @browser.click '.link-to-other-page'
    assert.equal '/other-page.html', @browser.getPath()

  it 'by refreshing', ->
    @browser.navigateTo '/'
    assert.equal 'statuscode', 200, @browser.getStatusCode()

    @browser.refresh()
    assert.equal 'statuscode', 200, @browser.getStatusCode()

    # No real way to assert this worked

  describe 'waiting for a url', ->
    it 'can work with a string', ->
      @browser.navigateTo '/redirect-after.html'
      assert.equal 'statuscode', 200, @browser.getStatusCode()

      @browser.waitForUrl 'http://127.0.0.1:4445/index.html'

    it 'can work with a regex', ->
      @browser.navigateTo '/redirect-after.html'
      assert.equal 'statuscode', 200, @browser.getStatusCode()

      @browser.waitForUrl /\/index.html/

    it 'can fail', ->
      @browser.navigateTo '/index.html'
      assert.equal 'statuscode', 200, @browser.getStatusCode()

      error = assert.throws => @browser.waitForUrl '/some-random-place.html', 5
      expectedError = 'Timed out (5ms) waiting for url (/some-random-place.html). Last url was: http://127.0.0.1:4445/index.html'
      assert.equal expectedError, error.message

  describe 'waiting for a path', ->
    it 'can work with a string', ->
      @browser.navigateTo '/redirect-after.html'
      assert.equal 'statuscode', 200, @browser.getStatusCode()

      @browser.waitForPath '/index.html'

    it 'can work with a regex', ->
      @browser.navigateTo '/redirect-after.html'
      assert.equal 'statuscode', 200, @browser.getStatusCode()

      @browser.waitForPath /index.html/

