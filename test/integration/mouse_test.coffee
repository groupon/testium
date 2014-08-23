{getBrowser} = require '../../lib/index'
assert = require 'assertive'

describe.only 'mouse', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/mouse.html'
    @browser.assert.httpStatus 200

  it 'mouseover', (done) ->
    @browser.mouseOver('#mouseover-div')

    setTimeout (=>
      log = @browser.getElement('#log').get('text')

      console.log @browser.getConsoleLogs()

      assert.equal 'mouseover triggered', log
      done()
    ), 1000

