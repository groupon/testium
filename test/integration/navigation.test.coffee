injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'navigation', ->
  before injectBrowser()

  it 'directly', ->
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

  it 'with a query arg', ->
    @browser.navigateTo '/', query: { 'a b': 'München', x: 0 }
    @browser.assert.httpStatus 200

    @browser.waitForUrl 'http://127.0.0.1:4445/?a%20b=M%C3%BCnchen&x=0', 100

  it 'with a query string and query arg', ->
    @browser.navigateTo '/?x=0', query: { 'a b': 'München' }
    @browser.assert.httpStatus 200

    @browser.waitForUrl 'http://127.0.0.1:4445/?x=0&a%20b=M%C3%BCnchen', 100

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

    describe 'groks url and query object', ->
      it 'can make its own query regexp', ->
        @browser.navigateTo '/redirect-to-query.html'
        @browser.waitForUrl '/index.html',
          'a b': 'A B'
          c: '1,7'
        @browser.assert.httpStatus 200

      it 'can find query arguments in any order', ->
        @browser.navigateTo '/redirect-to-query.html'
        @browser.waitForUrl '/index.html',
          c: '1,7'
          'a b': 'A B'

      it 'can handle regexp query arguments', ->
        @browser.navigateTo '/redirect-to-query.html'
        @browser.waitForUrl '/index.html',
          c: /[\d,]+/
          'a b': 'A B'

      it 'detects non-matches too', ->
        @browser.navigateTo '/redirect-to-query.html'

        error = assert.throws => @browser.waitForUrl '/index.html', no: 'q', 200
        assert.match /Timed out .* waiting for url/, error.message

  describe 'waiting for a path', ->
    it 'can work with a string', ->
      @browser.navigateTo '/redirect-after.html'
      @browser.assert.httpStatus 200

      @browser.waitForPath '/index.html'

    it 'can work with a regex', ->
      @browser.navigateTo '/redirect-after.html'
      @browser.assert.httpStatus 200

      @browser.waitForPath /index.html/

