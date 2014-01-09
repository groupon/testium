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

async = require 'async'
logError = require '../log/error'
{unlinkSync, existsSync} = require 'fs'

module.exports = (seleniumProcess, proxyProcess, callback) ->
  cleanupChrome()
  cleanupPhantomJS()

  async.parallel [
    (taskDone) -> killProcess('selenium', seleniumProcess, taskDone)
    (taskDone) -> killProcess('proxy', proxyProcess, taskDone)
  ], callback

cleanupChrome = ->
  file = "#{__dirname}/../../libpeerconnection.log"
  try
    unlinkSync file if existsSync file
  catch error
    logError error

cleanupPhantomJS = ->
  file = "#{__dirname}/../../phantomjsdriver.log"
  try
    unlinkSync file if existsSync file
  catch error
    logError error

killProcess = (name, proc, callback) ->
  return callback() unless proc?
  return callback() if proc.killed

  error = null
  exited = false
  proc.on 'error', (err) ->
    error = err
  proc.on 'exit', ->
    exited = true
    callback(error)

  proc.kill('SIGKILL')

  setTimeout (->
    if !exited
      callback new Error "[testium] failed to cleanup #{name} (pid=#{proc.pid}) process; check the #{name}.log."
  ), 2000

