{execFile} = require 'child_process'

assert = require 'assertive'
rimraf = require 'rimraf'
{extend} = require 'lodash'

LOG_DIRECTORY = "#{__dirname}/no_app_log"
TEST_FILE = 'test/no_app_test.test.coffee'

ENV_OVERRIDES = {
  testium_app: null
}

describe 'App not Required', ->
  before "rm -rf #{LOG_DIRECTORY}", (done) ->
    rimraf LOG_DIRECTORY, done

  it 'run the no_app test', (done) ->
    @timeout 10000

    mocha = execFile './node_modules/.bin/mocha', [ TEST_FILE ], {
      env: extend(ENV_OVERRIDES, process.env)
    }, (err, @stdout, @stderr) =>
      try
        assert.equal 'mocha exit code', 0, mocha.exitCode
        done()
      catch exitCodeError
        console.error @stderr
        done exitCodeError

