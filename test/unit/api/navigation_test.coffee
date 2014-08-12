Navigation = require '../../../lib/api/navigation'
assert = require 'assertive'

describe 'navigation', ->
  dummyContext =
    urlRoot: ''
    proxyCommandRoot: ''
  driver =
    http:
      post: ->
    refresh: ->
    getUrl: ->
    navigateTo: ->
    getCurrentWindowHandle: ->
  navigation = Navigation(driver)

  describe '#navigateTo', ->
    it 'fails if url is undefined', ->
      assert.throws ->
        navigation.navigateTo.call(dummyContext, undefined)

    it 'fails if url is not a String', ->
      assert.throws ->
        navigation.navigateTo.call(dummyContext, ->)

    it 'suceeds if all conditions are met', ->
      navigation.navigateTo.call(dummyContext, 'http://127.0.0.1:3000')

