injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'page data', ->
  before injectBrowser()

  before ->
    @browser.navigateTo '/'

  it 'title', ->
    title = @browser.getPageTitle()
    assert.equal 'Test Title', title

  it 'source', ->
    source = @browser.getPageSource()
    assert.include 'DOCTYPE', source
