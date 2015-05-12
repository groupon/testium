injectBrowser = require '../mocha'
assert = require 'assertive'

describe 'without an app', ->
  before injectBrowser()

  it 'can hit the internet', ->
    @browser.navigateTo 'http://google.com'

