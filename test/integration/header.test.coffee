injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'headers', ->
  before injectBrowser()

  describe 'can be retireved', ->
    before ->
      @browser.navigateTo '/'
      @browser.assert.httpStatus 200

    it 'as a group', ->
      headers = @browser.getHeaders()
      contentType = headers['content-type']
      assert.equal "text/html", contentType

    it 'individually', ->
      contentType = @browser.getHeader('content-type')
      assert.equal "text/html", contentType

  describe 'can be set', ->
    before ->
      @browser.navigateTo '/echo',
        headers:
          'x-something': 'that place'

    it 'to new values', ->
      source = @browser.getElement('body').get('text')
      body = JSON.parse source
      assert.equal body.headers['x-something'], 'that place'

