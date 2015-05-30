'use strict'

assert = require 'assertive'
injectBrowser = require '../mocha'

describe 'Happy test', ->
  before injectBrowser()

  it 'that exits without any exceptions', ->
    assert.equal 1, 1
