assert = require 'assertive'
inferCapabilities = require '../../../lib/api/capabilities'

describe 'capabilities', ->
  describe 'consoleLogs', ->
    describe 'in real browsers', ->
      it 'is always "all"', ->
        capabilities =
          browserName: 'chrome'
        expected =
          browserName: 'chrome'
          consoleLogs: 'all'
        inferred = inferCapabilities(capabilities)
        assert.deepEqual expected, inferred

    describe 'in phantomjs', ->
      it 'is "basic" if >= 1.9.7', ->
        capabilities =
          browserName: 'phantomjs'
          version: '1.9.7'
        expected =
          browserName: 'phantomjs'
          version: '1.9.7'
          consoleLogs: 'basic'
        inferred = inferCapabilities(capabilities)
        assert.deepEqual expected, inferred

      it 'is "none" if < 1.9.7', ->
        capabilities =
          browserName: 'phantomjs'
          version: '1.9.2'
        expected =
          browserName: 'phantomjs'
          version: '1.9.2'
          consoleLogs: 'none'
        inferred = inferCapabilities(capabilities)
        assert.deepEqual expected, inferred

