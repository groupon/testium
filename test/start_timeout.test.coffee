fs = require 'fs'
{execFile} = require 'child_process'

assert = require 'assertive'
rimraf = require 'rimraf'
{extend} = require 'lodash'

LOG_DIRECTORY = "#{__dirname}/start_timeout_log"
TEST_FILE = 'test/integration/cookie.test.coffee'

ENV_OVERRIDES = {
  testium_app__timeout: 250
  testium_logDirectory: LOG_DIRECTORY
  never_listen: '1'
}

describe 'App startup timeout', ->
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

  it 'mentions helpful details', ->
    assert.include 'command: coffee', @stderr
    assert.include 'test/app', @stderr
    assert.include 'timeout: 250ms', @stderr
    assert.include 'test/start_timeout_log/application.log', @stderr
    assert.include '> Refusing to listen', @stderr
