fs = require 'fs'
{execFile} = require 'child_process'

assert = require 'assertive'
rimraf = require 'rimraf'
{extend} = require 'lodash'

LOG_DIRECTORY = "#{__dirname}/screenshot_integration_log"
SCREENSHOT_DIRECTORY = "#{__dirname}/screenshot_integration_log/screenshots"
TEST_FILE = 'test/screenshot_integration/force_screenshot.hidden.coffee'

ENV_OVERRIDES = {
  testium_logDirectory: LOG_DIRECTORY
  testium_screenshotDirectory: SCREENSHOT_DIRECTORY
}

describe 'screenshots', ->
  before "rm -rf #{LOG_DIRECTORY}", (done) ->
    rimraf LOG_DIRECTORY, done

  before 'run failing test suite', (done) ->
    @timeout 10000
    mocha = execFile './node_modules/.bin/mocha', [ TEST_FILE ], {
      env: extend(ENV_OVERRIDES, process.env)
    }, (err, @stdout, @stderr) =>
      try
        assert.equal 2, mocha.exitCode
        done()
      catch exitCodeError
        console.log "Error: #{err.stack}"
        console.log "stdout: #{@stdout}"
        console.log "stderr: #{@stderr}"
        done exitCodeError

  before "readdir #{SCREENSHOT_DIRECTORY}", ->
    @files = fs.readdirSync SCREENSHOT_DIRECTORY
    @files.sort()

  it 'creates two screenshots', ->
    assert.deepEqual [
      'forced_screenshot_my_test.png',
      'forced_screenshot_some_sPecial_chars.png'
    ], @files
