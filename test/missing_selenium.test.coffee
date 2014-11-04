fs = require 'fs'
{execFile} = require 'child_process'

assert = require 'assertive'
rimraf = require 'rimraf'
{extend} = require 'lodash'

LOG_DIRECTORY = "#{__dirname}/missing_selenium_log"
TEST_FILE = 'test/integration/cookie.test.coffee'

ENV_OVERRIDES = {
  testium_browser: 'firefox'
  testium_selenium__jar: '/tmp/no_such_jar.jar'
  testium_logDirectory: LOG_DIRECTORY
}

describe 'Missing selenium', ->
  before "rm -rf #{LOG_DIRECTORY}", (done) ->
    rimraf LOG_DIRECTORY, done

  before 'run failing test suite', (done) ->
    @timeout 10000
    mocha = execFile 'mocha', [ TEST_FILE ], {
      env: extend(ENV_OVERRIDES, process.env)
    }, (err, @stdout, @stderr) =>
      try
        assert.equal 1, mocha.exitCode
        done()
      catch err
        console.log stdout
        console.log stderr
        done err

  it 'mentions useful options', ->
    assert.include 'testium --download-selenium', @stderr
    assert.include '[selenium]\njar =', @stderr
