{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'dialogs', ->
  if !getBrowser().capabilities.handlesAlerts
    browserName = getBrowser().capabilities.browserName
    xit "skipping tests because browser #{browserName} doesn't support alerts"
  else
    before ->
      @browser = getBrowser()
      @browser.navigateTo '/'
      @browser.assert.httpStatus 200

      @target = @browser.getElement '#alert_target'
      @browser.click '.link_to_clear_alert_target'

    describe 'alert', ->
      beforeEach ->
        @browser.click '.link_to_open_an_alert'

      it "can get an alert text", ->
        text = @browser.alert.getText()
        @browser.alert.accept()
        assert.equal 'Alert text was not found', 'An alert!', text

      it "can accept an alert", ->
        @browser.alert.accept()
        assert.equal 'alerted', @target.get('text')

      it "can dismiss an alert", ->
        @browser.alert.dismiss()
        assert.equal 'alerted', @target.get('text')

    describe 'confirm', ->
      beforeEach ->
        @browser.click '.link_to_open_a_confirm'

      it "can get confirm text", ->
        text = @browser.alert.getText()
        @browser.alert.accept()
        assert.equal 'Confirm text was not found', 'A confirmation!', text

      it "can accept a confirm", ->
        @browser.alert.accept()
        assert.equal 'confirmed', @target.get('text')

      it "can dismiss a confirm", ->
        @browser.alert.dismiss()
        assert.equal 'dismissed', @target.get('text')

    describe 'prompt', ->
      beforeEach ->
        @browser.click '.link_to_open_a_prompt'

      it "can get prompt text", ->
        text = @browser.alert.getText()
        @browser.alert.accept()
        assert.equal 'Confirm text was not found', 'A prompt!', text

      it "can send text to and accept a prompt", ->
        @browser.alert.type 'Some words'
        @browser.alert.accept()
        assert.equal 'Some words', @target.get('text')

      it "can dismiss a prompt", ->
        @browser.alert.dismiss()
        assert.equal 'dismissed', @target.get('text')
