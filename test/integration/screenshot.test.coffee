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

