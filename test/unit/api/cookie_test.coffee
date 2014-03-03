Cookie = require '../../../lib/api/cookie'
assert = require 'assertive'

describe 'cookie', ->
  describe '#setCookie', ->
    driver =
      setCookie: ->
    cookie = Cookie(driver)

    it 'fails if cookie is undefined', ->
      assert.throws ->
        cookie.setCookie(undefined)

    it 'fails if cookie does not contain name', ->
      assert.throws ->
        cookie.setCookie {value: 'chicago'}

    it 'fails if cookie does not contain value', ->
      assert.throws ->
        cookie.setCookie {name: 'division'}

  describe '#getCookie', ->
    driver =
      getCookies: -> []
    cookie = Cookie(driver)

    it 'fails if name is undefined', ->
      assert.throws ->
        cookie.getCookie(undefined)

    it 'fails if name is not a String', ->
      assert.throws ->
        cookie.getCookie(->)

    it 'succeeds if name is a String', ->
      cookie.getCookie('division')

  describe '#getHeader', ->
    testiumCookie =
      name: '_testium_'
      value: 'eyJoZWFkZXJzIjp7InNlcnZlciI6Im5vZGUtc3RhdGljLzAuNy4wIiwiY2FjaGUtY29udHJvbCI6Im1heC1hZ2U9MzYwMCIsImV0YWciOiJcIjE1ODI5ODQtMjUyNi0xMzkxNTI5MDM2MDAwXCIiLCJkYXRlIjoiTW9uLCAwMyBNYXIgMjAxNCAwNDo0MDoxNCBHTVQiLCJsYXN0LW1vZGlmaWVkIjoiVHVlLCAwNCBGZWIgMjAxNCAxNTo1MDozNiBHTVQiLCJjb250ZW50LXR5cGUiOiJ0ZXh0L2h0bWwiLCJjb250ZW50LWxlbmd0aCI6IjI1MjYiLCJjb25uZWN0aW9uIjoia2VlcC1hbGl2ZSIsIkNhY2hlLUNvbnRyb2wiOiJuby1zdG9yZSJ9LCJzdGF0dXNDb2RlIjoyMDB9'
    driver =
      getCookies: -> [testiumCookie]
    cookie = Cookie(driver)

    it 'fails if name is undefined', ->
      assert.throws ->
        cookie.getHeader(undefined)

    it 'fails if name is not a String', ->
      assert.throws ->
        cookie.getHeader(->)

    it 'succeeds if name is a String', ->
      cookie.getHeader('user-agent')

