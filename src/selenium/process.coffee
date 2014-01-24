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

SELENIUM_PORT = 4444
SELENIUM_TIMEOUT = 90000 # 90 seconds
PROXY_PORT = 4445
PROXY_TIMEOUT = 1000 # 1 second
DEFAULT_LOG_DIRECTORY = "#{__dirname}/../../log"

DEBUG = false

path = require 'path'
mkdirp = require 'mkdirp'
async = require 'async'
moment = require 'moment'
portscanner = require 'portscanner'
logError = require '../log/error'
{createWriteStream} = require 'fs'
{spawn} = require 'child_process'

module.exports = (seleniumServerUrl, javaHeapSize, logDirectory, applicationPort, callback) ->
  logDirectory ?= DEFAULT_LOG_DIRECTORY
  mkdirp.sync logDirectory

  seleniumLog = createLog("#{logDirectory}/selenium.log")
  proxyLog = createLog("#{logDirectory}/proxy.log")

  tasks =
    proxy: startProxy(applicationPort, proxyLog)

  if !seleniumServerUrl
    tasks.selenium = startSelenium(seleniumLog, javaHeapSize)

  async.parallel tasks, (error, processes) ->
    return callback(error) if error?

    callback(null, processes)

waitForPort = (port, timeout, callback) ->
  startTime = Date.now()
  check = ->
    portscanner.checkPortStatus port, '127.0.0.1', (error, status) ->
      logError error.message if error?

      if error? || status == 'closed'
        if (Date.now() - startTime) >= timeout
          timedOut = true
          return callback timedOut
        setTimeout(check, 100)
      else
        callback()

  check()

createSeleniumArguments = ->
  chromeDriverPath = path.join __dirname, '../../bin/chromedriver'
  chromeArgs = '--disable-application-cache --media-cache-size=1 --disk-cache-size=1 --disk-cache-dir=/dev/null --disable-cache'
  firefoxProfilePath = path.join __dirname, './firefox_profile.js'

  args = [
    "-Dwebdriver.chrome.driver=#{chromeDriverPath}"
    "-Dwebdriver.chrome.args=\"#{chromeArgs}\""
    '-firefoxProfileTemplate', firefoxProfilePath
    '-ensureCleanSession'
  ]

  args.push '-debug' if DEBUG
  args

startSelenium = (logStream, javaHeapSize=256) ->
  (callback) ->
    logStream.log "Starting selenium"

    jarPath = path.join __dirname, '../../bin/selenium.jar'
    javaHeapArg = "-Xmx#{javaHeapSize}m"
    args = [javaHeapArg, '-jar', jarPath].concat createSeleniumArguments()
    seleniumProcess = spawn 'java', args

    seleniumProcess.stdout.pipe logStream
    seleniumProcess.stderr.pipe logStream

    logStream.log "waiting for selenium to listen on port #{SELENIUM_PORT}"
    waitForPort SELENIUM_PORT, SELENIUM_TIMEOUT, (timedOut) ->
      if timedOut
        return callback new Error "Timeout occurred waiting for selenium to be ready on port #{SELENIUM_PORT}."

      logStream.log "selenium is ready!"
      callback(null, seleniumProcess)

startProxy = (applicationPort, logStream) ->
  (callback) ->
    logStream.log "Starting webdriver proxy"

    proxyPath = path.join __dirname, "../proxy/index.js"
    proxyProcess = spawn 'node', [proxyPath, applicationPort]

    proxyProcess.stdout.pipe logStream
    proxyProcess.stderr.pipe logStream

    logStream.log "waiting for webdriver proxy to listen on port #{PROXY_PORT}"
    waitForPort PROXY_PORT, PROXY_TIMEOUT, (timedOut) ->
      if timedOut
        return callback new Error "Timeout occurred waiting for the testium proxy to be ready on port #{PROXY_PORT}."

      logStream.log "webdriver proxy is ready!"
      callback(null, proxyProcess)

createLog = (logPath) ->
  stream = createWriteStream logPath
  stream.log = (message) ->
    timestamp = moment().format('HH:mm:ss.SSS')
    @write "[SERVICE] #{timestamp} - #{message}\n"
  stream

