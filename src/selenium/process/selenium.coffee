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

SELENIUM_PORT = 4444
SELENIUM_TIMEOUT = 90000 # 90 seconds

path = require 'path'
spawn = require './spawn'
port = require './port'

createSeleniumArguments = ->
  chromeDriverPath = path.join __dirname, '../../../bin/chromedriver'
  chromeArgs = '--disable-application-cache --media-cache-size=1 --disk-cache-size=1 --disk-cache-dir=/dev/null --disable-cache --disable-desktop-notifications'
  firefoxProfilePath = path.join __dirname, './firefox_profile.js'

  [
    "-Dwebdriver.chrome.driver=#{chromeDriverPath}"
    "-Dwebdriver.chrome.args=\"#{chromeArgs}\""
    '-firefoxProfileTemplate', firefoxProfilePath
    '-ensureCleanSession'
    '-debug'
  ]

spawnProcess = (logStream, javaHeapSize) ->
  jarPath = path.join __dirname, '../../../bin/selenium.jar'
  javaHeapArg = "-Xmx#{javaHeapSize}m"
  args = [javaHeapArg, '-jar', jarPath].concat createSeleniumArguments()

  spawn 'java', args, 'selenium', logStream

module.exports = (logStream, javaHeapSize=256) ->
  (parallelCallback) ->
    callback = (error, process) ->
      # skip short circuiting of async.parallel
      parallelCallback(null, {error, process})

    logStream.log "Starting selenium"

    port.isAvailable SELENIUM_PORT, (error, isAvailable) ->
      return callback(error) if error?

      if !isAvailable
        return callback new Error "Port #{SELENIUM_PORT} (requested by selenium) is already in use."

      seleniumProcess = spawnProcess(logStream, javaHeapSize)

      logStream.log "waiting for selenium to listen on port #{SELENIUM_PORT}"
      port.waitFor seleniumProcess, SELENIUM_PORT, SELENIUM_TIMEOUT, (error, timedOut) ->
        return callback(error) if error?
        if timedOut
          return callback new Error "Timeout occurred waiting for selenium to be ready on port #{SELENIUM_PORT}. Check the log at: #{logStream.path}"

        logStream.log "selenium is ready!"
        callback(null, seleniumProcess)

