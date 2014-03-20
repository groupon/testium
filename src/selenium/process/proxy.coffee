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

PROXY_PORT = 4445
PROXY_TIMEOUT = 1000 # 1 second

path = require 'path'
spawn = require './spawn'
port = require './port'

spawnProcess = (logStream, applicationPort) ->
  proxyPath = path.join __dirname, "../../proxy/index.js"
  args = [proxyPath, applicationPort]

  spawn 'node', args, 'testium proxy', logStream

module.exports = (applicationPort, logStream) ->
  (callback) ->
    logStream.log "Starting webdriver proxy"

    port.isAvailable PROXY_PORT, (error, isAvailable) ->
      return callback(error) if error?

      if !isAvailable
        return callback new Error "Port #{PROXY_PORT} (requested by testium proxy) is already in use."

      proxyProcess = spawnProcess(logStream, applicationPort)

      logStream.log "waiting for webdriver proxy to listen on port #{PROXY_PORT} and proxy to #{applicationPort}"
      port.waitFor proxyProcess, PROXY_PORT, PROXY_TIMEOUT, (error, timedOut) ->
        return callback(error) if error?
        if timedOut
          return callback new Error "Timeout occurred waiting for the testium proxy to be ready on port #{PROXY_PORT}. Check the log at: #{logStream.path}"

        logStream.log "webdriver proxy is ready!"
        callback(null, proxyProcess)

