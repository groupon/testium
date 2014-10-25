injectBrowser = require '../../mocha'
assert = require 'assertive'
{browser} = require '../../lib/config'

describe 'dialogs', ->
  if browser == 'phantomjs'
    xit "skipping tests because browser phantomjs doesn't support alerts"
    return

  before injectBrowser()

  before ->
    @browser.navigateTo '/'
    @browser.assert.httpStatus 200

    @target = @browser.getElement '#alert_target'
    @browser.click '.link_to_clear_alert_target'

  xdescribe 'alert', ->
    beforeEach ->
      @browser.click '.link_to_open_an_alert'

    it "can get an alert text", ->
      text = @browser.getAlertText()
      @browser.acceptAlert()
      assert.equal 'Alert text was not found', 'An alert!', text

    it "can accept an alert", ->
      @browser.acceptAlert()
      assert.equal 'alerted', @target.get('text')

    it "can dismiss an alert", ->
      @browser.dismissAlert()
      assert.equal 'alerted', @target.get('text')

  describe 'confirm', ->
    beforeEach ->
      @browser.click '.link_to_open_a_confirm'

    it "can get confirm text", ->
      text = @browser.getAlertText()
      @browser.acceptAlert()
      assert.equal 'Confirm text was not found', 'A confirmation!', text

    it "can accept a confirm", ->
      @browser.acceptAlert()
      assert.equal 'confirmed', @target.get('text')

    it "can dismiss a confirm", ->
      @browser.dismissAlert()
      assert.equal 'dismissed', @target.get('text')

  describe 'prompt', ->
    beforeEach ->
      @browser.click '.link_to_open_a_prompt'

    it "can get prompt text", ->
      text = @browser.getAlertText()
      @browser.acceptAlert()
      assert.equal 'Confirm text was not found', 'A prompt!', text

    it "can send text to and accept a prompt", ->
      @browser.typeAlert 'Some words'
      @browser.acceptAlert()
      assert.equal 'Some words', @target.get('text')

    it "can dismiss a prompt", ->
      @browser.dismissAlert()
      assert.equal 'dismissed', @target.get('text')
