Browser = require '../../../lib/browser'
assert = require 'assertive'

class FakeWebDriver

describe 'API', ->
  describe 'construction', ->
    driver = new FakeWebDriver()
    proxyUrl = 'http://127.0.0.1:1000'
    commandUrl = 'http://127.0.0.1:2000'

    it 'fails if driver is undefined', ->
      assert.throws ->
        new Browser undefined, proxyUrl, commandUrl

    it 'fails if driver is not an object', ->
      assert.throws ->
        new Browser 'Not a driver', proxyUrl, commandUrl

    it 'fails if proxyUrl is not a String', ->
      assert.throws ->
        new Browser driver, 1000, commandUrl

    it 'fails if proxyUrl is undefined', ->
      assert.throws ->
        new Browser driver, undefined, commandUrl

    it 'fails if commandUrl is undefined', ->
      assert.throws ->
        new Browser driver, proxyUrl, undefined

    it 'fails if commandUrl is not a String', ->
      err = assert.throws ->
        new Browser driver, proxyUrl, 999
      assert.include '''
        new Browser(driver, proxyUrl, commandUrl) - requires (String) commandUrl
      ''', err.message

    it 'succeeds if all conditions are met', ->
      new Browser driver, proxyUrl, commandUrl

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
