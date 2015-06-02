'use strict'

assert = require 'assertive'
injectBrowser = require '../mocha'

# kill PATH for this subshell so testium can't spawn node, coffee or phantomjs
process.env.PATH = ''

describe 'No child test', ->
  before injectBrowser()

  it 'that deliberately hangs because we want the error to be triggered', (done) ->
    setTimeout done, 60000
