{assert, getBrowser} = require '../../lib/index'

describe 'forced screenshot', ->
  before ->
    @browser = getBrowser()

  it 'my test', ->
    @browser.navigateTo '/'
    # This is supposed to be failing, the real status code is 200
    assert.equal 'statuscode', 418, @browser.getStatusCode()

  it 'some !%#(*.>:; sPecial  chars', ->
    @browser.navigateTo '/'
    # Supposed to be failing as well, actual text is "only one here"
    @browser.assert.elementHasText('.only', 'not on the page')

  it 'does not fail', ->
    # empty test should never fail
    # This makes sure that when everything is fine we do not take
    # screenshots
