{getBrowser} = require '../../lib/index'
assert = require 'assertive'

getIndexScreenshot = (browser) ->
  browser.navigateTo '/'
  browser.getScreenshot()

describe 'screenshots', ->
  before ->
    @browser = getBrowser()

  describe 'taking', ->
    before ->
      @browser.navigateTo '/'
      assert.equal 200, @browser.getStatusCode()
      @indexScreenshot ?= getIndexScreenshot(@browser)

    it 'captures the page', ->
      assert.truthy @indexScreenshot.length > 0

    it 'can be scoped to a selector', ->
      formScreenshot = @browser.getScreenshot('#the-form')
      assert.truthy 'selector screenshot is smaller than the page', formScreenshot.length < @indexScreenshot.length

  describe 'comparing', ->
    it 'to itself succeeds', ->
      @browser.assert.imagesMatch(@indexScreenshot, @indexScreenshot)

    it 'to something else fails', ->
      @indexScreenshot ?= getIndexScreenshot(@browser)
      @browser.navigateTo '/other-page.html'
      otherScreenshot = @browser.getScreenshot()

      error = assert.throws =>
        @browser.assert.imagesMatch(@indexScreenshot, otherScreenshot)
      expectedError = /^Images are .+ different! Tolerance was 0\.$/
      assert.match expectedError, error.message

    it 'allows tolerance', ->
      @indexScreenshot ?= getIndexScreenshot(@browser)
      @browser.navigateTo '/index-diff.html'
      diffScreenshot = @browser.getScreenshot()
      @browser.assert.imagesMatch(@indexScreenshot, diffScreenshot, 60.00)

