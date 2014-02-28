Api = require '../../../lib/api'
assert = require 'assertive'
bond = require 'bondjs'

describe 'API', ->
  describe 'construction', ->
    targetPort = 1000
    proxyCommandPort = 2000
    webdriverServerUrl = 'http://127.0.0.1:4444'
    desiredCapabilities = {browser: 'phantomjs'}

    it 'fails if targetPort is undefined', ->
      assert.throws ->
        new Api undefined, proxyCommandPort, webdriverServerUrl, desiredCapabilities

    it 'fails if targetPort is not a Number', ->
      assert.throws ->
        new Api '1000', proxyCommandPort, webdriverServerUrl, desiredCapabilities

    it 'fails if proxyCommandPort is undefined', ->
      assert.throws ->
        new Api targetPort, undefined, webdriverServerUrl, desiredCapabilities

    it 'fails if proxyCommandPort is not a Number', ->
      assert.throws ->
        new Api targetPort, '2000', webdriverServerUrl, desiredCapabilities

    it 'fails if webdriverServerUrl is undefined', ->
      assert.throws ->
        new Api targetPort, proxyCommandPort, undefined, desiredCapabilities

    it 'fails if webdriverServerUrl is not a String', ->
      assert.throws ->
        new Api targetPort, proxyCommandPort, 999, desiredCapabilities

    it 'fails if desiredCapabilities is not an Object', ->
      assert.throws ->
        new Api targetPort, proxyCommandPort, webdriverServerUrl, undefined

    it 'fails if desiredCapabilities is not an Object', ->
      assert.throws ->
        new Api targetPort, proxyCommandPort, webdriverServerUrl, (->)

    it 'succeeds if all conditions are met', ->
      # API construction succeds
      # Connection to an actual webdriver server fails
      error = assert.throws ->
        new Api targetPort, proxyCommandPort, webdriverServerUrl, desiredCapabilities
      assert.equal error.message, "Couldn't connect to server"

  describe '#close', ->
    dummyContext =
      driver:
        close: bond()
      log:
        flush: bond()

    it 'fails if callback is not a Function', ->
      assert.throws ->
        Api.prototype.close.call(dummyContext, undefined)

    it 'succeeds if callback is a function', ->
      Api.prototype.close.call(dummyContext, ->)
      assert.truthy dummyContext.driver.close.called
      assert.truthy dummyContext.log.flush.called

  describe '#evaluate', ->
    dummyContext =
      driver:
        evaluate: bond()

    it 'fails if clientFunction is undefined', ->
      assert.throws ->
        Api.prototype.evaluate.call(dummyContext, undefined)

    it 'fails if clientFunction is not a Function or String', ->
      assert.throws ->
        Api.prototype.evaluate.call(dummyContext, 999)

    it 'succeeds if all conditions are met', ->
      Api.prototype.evaluate.call(dummyContext, ->)
      assert.truthy dummyContext.driver.evaluate.called

