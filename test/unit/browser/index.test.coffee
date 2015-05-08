Browser = require '../../../lib/browser'
assert = require 'assertive'

class FakeWebDriver

describe 'API', ->
  describe 'construction', ->
    driver = new FakeWebDriver()
    targetUrl = 'http://127.0.0.1:1000'
    commandUrl = 'http://127.0.0.1:2000'

    it 'fails if driver is undefined', ->
      assert.throws ->
        new Browser undefined, targetUrl, commandUrl

    it 'fails if driver is not an object', ->
      assert.throws ->
        new Browser 'Not a driver', targetUrl, commandUrl

    it 'succeeds if all conditions are met', ->
      new Browser driver, targetUrl, commandUrl

  describe '#close', ->
    it 'fails if callback is not a Function', ->
      err = assert.throws ->
        Browser.prototype.close.call({}, undefined)
      assert.include 'requires (Function) callback', err.message

    it 'succeeds if callback is a function', (done) ->
      dummyContext =
        driver:
          close: -> done()
      Browser.prototype.close.call(dummyContext, ->)

  describe '#evaluate', ->
    it 'fails if clientFunction is undefined', ->
      err = assert.throws ->
        Browser.prototype.evaluate.call({}, undefined)
      assert.include 'requires (Function|String) clientFunction', err.message

    it 'fails if clientFunction is not a Function or String', ->
      err = assert.throws ->
        Browser.prototype.evaluate.call({}, 999)
      assert.include 'requires (Function|String) clientFunction', err.message

    it 'succeeds if all conditions are met', (done) ->
      dummyContext =
        driver:
          evaluate: -> done()
      Browser.prototype.evaluate.call(dummyContext, ->)
