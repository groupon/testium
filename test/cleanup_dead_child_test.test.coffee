'use strict'

assert = require 'assertive'
injectBrowser = require '../mocha'

describe 'Dead child test', ->
  before injectBrowser()

  it 'that deliberately hangs for a long time because we want the app to die first', (done) ->
    setTimeout done, 60000
