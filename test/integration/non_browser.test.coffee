http = require 'http'

injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'Non-browser test', ->
  before injectBrowser()

  it 'can make a request without using the browser', (done) ->
    http.get "#{@browser.appUrl}/echo", (response) ->
      assert.equal 200, response.statusCode
      done()
