###
Copyright (c) 2014, Groupon, Inc.
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

{spawn} = require 'child_process'
{readFileSync} = require 'fs'

portscanner = require 'portscanner'
{extend, omit} = require 'lodash'
debug = require('debug')('testium:processes')

getAppLogWithQuote = (proc) ->
  logQuote =
    try
      createTailQuote readFileSync(proc.logPath, 'utf8'), 20
    catch err
      "(failed to load log: #{err.message})"

  """
  App output (last 20 lines):

  #{logQuote}

  See the full log at: #{proc.logPath}
  """

procCrashedError = (proc) ->
  message =
    """
    Process \"#{proc.name}\" crashed with code #{proc.exitCode}.
    #{getAppLogWithQuote proc}
    """
  message += "\n#{proc.error.trim()}" if proc.error?.length > 0
  new Error message

niceTime = (ms) ->
  if ms > 1000 * 60
    "#{ms / 1000 / 60}min"
  else if ms > 1000
    "#{ms / 1000}s"
  else
    "#{ms}ms"

createTailQuote = (str, count) ->
  lines = str.split('\n').slice(-count)
  "> #{lines.join '\n> '}"

procTimedoutError = (proc, port, timeout) ->
  formatArguments = (args = []) ->
    return '(no arguments)' unless args.length
    args.join('\n           ')

  configSection =
    switch proc.name
      when 'application' then 'app'
      else proc.name

  message =
    """
    Process \"#{proc.name}\" did not start in time.

    Debug info:
    * command: #{proc.launchCommand}
               #{formatArguments proc.launchArguments}
    * cwd:     #{proc.workingDirectory}
    * port:    #{port}
    * timeout: #{niceTime timeout}

    If longer startup times for this process are expected,
    you can create a .testiumrc file in your project:

    ```
    ; see: https://www.npmjs.org/package/rc
    [#{configSection}]
    timeout = 60000 ; time in ms
    ```

    #{getAppLogWithQuote proc}
    """
  message += "\n#{proc.error.trim()}" if proc.error?.length > 0
  new Error message

waitFor = (proc, port, timeout, callback) ->
  if proc.exitCode?
    error = procCrashedError(proc)
    return callback(error)

  procName = proc.name

  startTime = Date.now()
  check = ->
    debug 'Checking for %s on port %s', procName, port
    portscanner.checkPortStatus port, '127.0.0.1', (error, status) ->
      if proc.exitCode?
        error = procCrashedError(proc)
        return callback(error)

      if error? || status == 'closed'
        if (Date.now() - startTime) >= timeout
          return callback(procTimedoutError proc, port, timeout)
        setTimeout(check, 100)
      else
        callback()

  check()

spawnServer = (logs, name, cmd, args, opts, cb) ->
  {port, timeout} = opts
  timeout ?= 1000

  logs.openLogFile name, 'w+', (error, results) ->
    return cb(error) if error?
    {fd: logHandle, filename: logPath} = results

    spawnOpts = extend {
      stdio: [ 'ignore', logHandle, logHandle ]
    }, omit(opts, 'port', 'timeout')
    spawnOpts.cwd ?= process.cwd()

    child = spawn cmd, args, spawnOpts
    child.baseUrl = "http://127.0.0.1:#{port}"
    child.logPath = logPath
    child.logHandle = logHandle
    child.launchCommand = cmd
    child.launchArguments = args
    child.workingDirectory = spawnOpts.cwd
    child.name = name

    process.on 'exit', ->
      try child.kill()
      catch err
        console.error err.stack

    process.on 'uncaughtException', (error) ->
      try child.kill()
      catch err
        console.error err.stack
      throw error

    debug 'start %s on port %s', name, port
    waitFor child, port, timeout, (error) ->
      debug 'started %s', name, error
      return cb(error) if error?
      cb null, child

module.exports = { spawnServer }
