'use strict'

assert = require 'assertive'
injectBrowser = require '../mocha'

describe 'Failing test', ->
  before injectBrowser()

  it 'when running a test', ->
    assert.equal 0, 1
