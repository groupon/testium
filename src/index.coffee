###
Copyright (c) 2013, Groupon, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

Neither the name of GROUPON nor the names of its contributors may be
used to endorse or promote products derived from this software without
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###

assert = require 'assertive'
async = require 'async'
{spawn} = require 'child_process'
selenium = require './selenium'
{getBrowser} = require './test_setup/browser'

runTests = (options={}, callback) ->
  proc = spawn 'node', ['./test_runner/index.js'],
    cwd: __dirname
    stdio: [process.stdin, process.stdout, process.stderr, 'ipc']

  error = null
  proc.on 'error', (err) ->
    error = err

  proc.on 'exit', (exitCode) ->
    callback(error, exitCode)

  proc.send(options)

run = (options={}, callback) ->
  invocation = 'run(options, callback)'
  assert.truthy "#{invocation} - requires options.applicationPort", options.applicationPort
  assert.truthy "#{invocation} - requires options.tests", options.tests
  assert.truthy "#{invocation} - requires callback", callback

  selenium.start options.logDirectory, options.applicationPort, (error) ->
    return callback error if error?

    runTests options, (error, failedTests) ->
      selenium.cleanup (cleanupError) ->
        error ?= cleanupError
        if error? && cleanupError?
          error.inner = cleanupError
        callback(error, failedTests)

cleanup = selenium.cleanup
module.exports = { run, cleanup, getBrowser }

