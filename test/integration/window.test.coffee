injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'window api', ->
  before injectBrowser()

  describe 'frames', ->
    before ->
      @browser.navigateTo '/windows.html'
      @browser.assert.httpStatus 200

    it 'can be switched', ->
      @browser.switchToFrame('cool-frame')
      iframeContent = @browser.getElement('.in-iframe-only').get('text')
      @browser.switchToDefaultFrame()
      primaryContent = @browser.getElement('.in-iframe-only')?.get('text')
      assert.equal 'iframe content!', iframeContent
      assert.equal undefined, primaryContent

  describe 'popups', ->
    before ->
      @browser.navigateTo '/windows.html'
      @browser.assert.httpStatus 200

    it 'can be opened', ->
      @browser.click '#open-popup'
      @browser.switchToWindow('popup1')
      popupContent = @browser.getElement('.popup-only').get('text')
      @browser.closeWindow()
      @browser.switchToDefaultWindow()
      primaryContent = @browser.getElement('.popup-only')?.get('text')
      assert.equal 'popup content!', popupContent
      assert.equal undefined, primaryContent
