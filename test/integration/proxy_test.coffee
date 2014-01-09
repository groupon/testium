{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe 'proxy', ->
  before ->
    @browser = getBrowser()

  describe 'handles errors', ->
    it 'with no content type and preserves status code', ->
      @browser.navigateTo '/'
      assert.equal 'statuscode', 200, @browser.getStatusCode()

      @browser.navigateTo '/error'
      assert.equal 'statuscode', 500, @browser.getStatusCode()

    it 'that crash and preserves status code', ->
      @browser.navigateTo '/crash'
      assert.equal 'statuscode', 500, @browser.getStatusCode()

  it 'handles request abortion', (done) ->
    # loads a page that has a resource that will
    # be black holed
    @browser.navigateTo '/blackholed-resource.html'
    assert.equal 'statuscode', 200, @browser.getStatusCode()

    setTimeout (=>
      # when navigating away, the proxy should
      # abort the resource request;
      # this should not interfere with the new page load
      # or status code retrieval
      @browser.navigateTo '/'
      assert.equal 'statuscode', 200, @browser.getStatusCode()
      done()

      # this can't simply be sync
      # because firefox blocks dom-ready
      # if we don't wait on the client-side
    ), 50

  it 'handles hashes in urls', ->
    @browser.navigateTo '/#deals'
    assert.equal 'statuscode', 200, @browser.getStatusCode()

