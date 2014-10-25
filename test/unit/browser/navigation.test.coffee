NavigationMixin = require '../../../lib/browser/navigation'
assert = require 'assertive'
{extend, noop} = require 'lodash'

describe 'navigation', ->
  browser =
    proxyUrl: ''
    driver:
      http:
        post: ->
      refresh: ->
      getUrl: ->
      navigateTo: ->
      getCurrentWindowHandle: ->
  navigation = extend browser, NavigationMixin

  describe '#navigateTo', ->
    it 'fails if url is undefined', ->
      assert.throws ->
        navigation.navigateTo undefined

    it 'fails if url is not a String', ->
      assert.throws ->
        navigation.navigateTo noop

    it 'suceeds if all conditions are met', ->
      navigation.navigateTo 'http://127.0.0.1:3000'
