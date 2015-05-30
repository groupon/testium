{exec, execFile} = require 'child_process'

assert = require 'assertive'
rimraf = require 'rimraf'
{extend} = require 'lodash'

LOG_DIRECTORY = "#{__dirname}/cleanup_log"
ENV_OVERRIDES = 
  testium_logDirectory: LOG_DIRECTORY

getNumProcesses = (done) ->
  exec 'ps', (err, stdout, stderr) ->
    numProcesses = stdout.split('\n').length - 1 # header line
    done numProcesses

testFile = ({file, envOverrides, exitCode, done}) ->
  envOverrides ?= {testium_app: null}
  getNumProcesses (numProcessesBefore) ->

    mocha = execFile './node_modules/.bin/mocha', [ file ], {
      env: extend(envOverrides, ENV_OVERRIDES, process.env)
    }, (err, stdout, stderr) ->
      try
        assert.equal 'mocha exit code', exitCode, mocha.exitCode

        getNumProcesses (numProcessesAfter) ->
          assert.equal 'number of processes before & after', numProcessesBefore, numProcessesAfter
          done()

      catch exitCodeError
        console.error stderr
        done exitCodeError


describe 'Cleanup test', ->
  before "rm -rf #{LOG_DIRECTORY}", (done) ->
    rimraf LOG_DIRECTORY, done

  it 'cleans up all child apps after exit without any exceptions', (done) ->
    @timeout 10000
    testFile {
      file: 'test/cleanup_happy_test.test.coffee'
      exitCode: 0
      done
    }

  it 'cleans up all child apps after uncaught exception', (done) ->
    @timeout 10000
    testFile {
      file: 'test/cleanup_exception_test.test.coffee'
      exitCode: 7
      done
    }

  it 'cleans up all child apps after child dies', (done) ->
    @timeout 10000
    testFile {
      file: 'test/cleanup_dead_child_test.test.coffee'
      envOverrides:
        testium_app__command: './node_modules/.bin/coffee test/cleanup_dead_child_app.coffee'
        testium_app__port: 1337
      exitCode: 255
      done
    }
