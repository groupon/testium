injectBrowser = require '../../mocha'
assert = require 'assertive'

getIndexScreenshot = (browser) ->
  browser.navigateTo '/'
  browser.assert.httpStatus 200
  browser.getScreenshot()

describe 'screenshots', ->
  before injectBrowser()

  describe 'taking', ->
    before ->
      @indexScreenshot ?= getIndexScreenshot(@browser)

    it 'captures the page', ->
      assert.truthy @indexScreenshot.length > 0

    it 'can be scoped to a selector', ->
      formScreenshot = @browser.getScreenshot('#the-form')
      assert.truthy 'selector screenshot is smaller than the page', formScreenshot.length < @indexScreenshot.length

  describe 'comparing', ->
    before ->
      @indexScreenshot ?= getIndexScreenshot(@browser)

    it 'to itself succeeds', ->
      @browser.assert.imagesMatch(@indexScreenshot, @indexScreenshot)

    it 'to something else fails', ->
      @browser.navigateTo '/other-page.html'
      @browser.assert.httpStatus 200
      otherScreenshot = @browser.getScreenshot()

      error = assert.throws =>
        @browser.assert.imagesMatch(@indexScreenshot, otherScreenshot)
      expectedError = /^Images are .+ different! Tolerance was 0\.$/
      assert.match expectedError, error.message

    it 'allows tolerance', ->
      @browser.navigateTo '/index-diff.html'
      @browser.assert.httpStatus 200
      diffScreenshot = @browser.getScreenshot()
      @browser.assert.imagesMatch(@indexScreenshot, diffScreenshot, 60.00)

