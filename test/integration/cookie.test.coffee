injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'cookies', ->
  before injectBrowser()

  it 'can be set individually', ->
    @browser.setCookie
      name: 'test_cookie'
      value: '3'

    cookie = @browser.getCookie('test_cookie')
    assert.equal '3', cookie.value

  it 'can be set in groups', ->
    @browser.setCookies [
      { name: 'test_cookie1', value: '5' }
      { name: 'test_cookie2', value: '7' }
    ]

    cookie1 = @browser.getCookie('test_cookie1')
    cookie2 = @browser.getCookie('test_cookie2')

    assert.equal '5', cookie1.value
    assert.equal '7', cookie2.value

  it 'can be cleared as a group', ->
    @browser.setCookie
      name: 'test_cookie'
      value: '9'
    @browser.clearCookies()

    cookies = @browser.getCookies()

    assert.equal 0, cookies.length

  it 'can be cleared individually', ->
    @browser.setCookie
      name: 'test_cookie'
      value: '4'

    @browser.clearCookie 'test_cookie'

    cookie = @browser.getCookie('test_cookie')
    assert.falsey cookie

