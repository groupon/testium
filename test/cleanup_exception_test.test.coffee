'use strict'

assert = require 'assertive'
injectBrowser = require '../mocha'

describe 'Failing test', ->
  before injectBrowser()

  it 'when running an async test', (done) ->
    setTimeout ->
      assert.equal 0, 1
      done()
    , 1000
