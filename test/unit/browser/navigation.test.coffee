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
      navigateTo: (url) -> browser.fetched = url
      getCurrentWindowHandle: ->
  navigation = extend browser, NavigationMixin

  describe '#navigateTo', ->
    it 'fails if url is undefined', ->
      assert.throws ->
        navigation.navigateTo undefined

    it 'fails if query is not an object', ->
      assert.throws ->
        navigation.navigateTo '/anywhere', {query: 'non-object query'}

    it 'fails if url is not a String', ->
      assert.throws ->
        navigation.navigateTo noop

    it 'suceeds if all conditions are met', ->
      navigation.navigateTo 'http://127.0.0.1:3000'

    it 'composes urls correctly with given query args', ->
      navigation.navigateTo '/path?x=old#hash', query: {x: 'new', add: 'this'}
      assert.equal '/path?x=new&add=this#hash', browser.fetched

    it 'retains non-standard url queries', ->
      navigation.navigateTo '/?query-arg-without-value'
      assert.equal '/?query-arg-without-value', browser.fetched

    it 'retains the beginning of a url too', ->
      navigation.navigateTo 'http://www.google.com/', query: q: 'testium'
      assert.equal 'http://www.google.com/?q=testium', browser.fetched
