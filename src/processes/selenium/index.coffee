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

path = require 'path'
http = require 'http'
fs = require 'fs'

async = require 'async'
{partial} = require 'lodash'

{spawnServer} = require '../server'
{findOpenPort} = require '../port'
initLogs = require '../../logs'

BIN_PATH = path.join(__dirname, '..', '..', '..', 'bin')
SELENIUM_TIMEOUT = 90000 # 90 seconds
DEFAULT_JAR_PATH = path.join BIN_PATH, 'selenium.jar'
DEFAULT_CHROME_PATH = path.join BIN_PATH, 'chromedriver'

ensureSeleniumListening = (driverUrl, callback) ->
  req = http.get "#{driverUrl}/status", (response) ->
    callback null, { driverUrl }

  req.on 'error', (error) ->
    oldStack = error.stack
    oldStack = oldStack.substr(oldStack.indexOf('\n') + 1)
    error.message =
      """
      Error: Failed to connect to existing selenium server
             - url: #{driverUrl}
             - message: #{error.message}
      """
    error.stack = "#{error.message}\n#{oldStack}"
    callback error

createSeleniumArguments = (chromeDriverPath) ->
  chromeArgs = [
    '--disable-application-cache'
    '--media-cache-size=1'
    '--disk-cache-size=1'
    '--disk-cache-dir=/dev/null'
    '--disable-cache'
    '--disable-desktop-notifications'
  ].join(' ')
  firefoxProfilePath = path.join __dirname, './firefox_profile.js'

  [
    "-Dwebdriver.chrome.driver=#{chromeDriverPath}"
    "-Dwebdriver.chrome.args=\"#{chromeArgs}\""
    '-firefoxProfileTemplate', firefoxProfilePath
    '-ensureCleanSession'
    '-debug'
  ]

ensureBinaries = (browser, jarPath, chromeDriverPath, done) ->
  withPrettyError = (error) ->
    return done() unless error?
    oldStack = error.stack
    error.message =
      """
      Could not find required files for running selenium.
             - message: #{error.message}

      You can provide your own version of selenium via ~/.testiumrc:

      ```
      [selenium]
      jar = /path/to/selenium.jar
      ; For running tests in chrome:
      chromedriver = /path/to/chromedriver
      ```

      testium can also download these files for you,
      just execute the following before running your test suite:

      $ ./node_modules/.bin/testium --download-selenium

      testium will download selenium and chromedriver into this directory:
      #{BIN_PATH}
      """
    error.stack = "#{error.message}\n#{oldStack}"
    done error

  ensureChromeDriver = ->
    return done() if browser != 'chrome'
    fs.stat chromeDriverPath, withPrettyError

  fs.stat jarPath, (error) ->
    return withPrettyError(error) if error?
    ensureChromeDriver()

spawnSelenium = (config, callback) ->
  if config.selenium.serverUrl
    return ensureSeleniumListening config.selenium.serverUrl, callback

  logs = initLogs config

  jarPath = config.selenium.jar ?= DEFAULT_JAR_PATH
  chromeDriverPath = config.selenium.chromedriver ?= DEFAULT_CHROME_PATH

  async.auto {
    port: findOpenPort

    binaries: (done) ->
      ensureBinaries config.browser, jarPath, chromeDriverPath, done

    selenium: [ 'port', 'binaries', (done, {port}) ->
      args = [
        '-Xmx256m'
        '-jar', jarPath
        '-port', "#{port}"
      ].concat createSeleniumArguments(chromeDriverPath)
      options = { port, timeout: config.selenium.timeout }
      spawnServer logs, 'selenium', 'java', args, options, done
    ]
  }, (error, {selenium, port}) ->
    if selenium
      selenium.driverUrl = "#{selenium.baseUrl}/wd/hub"
    callback error, selenium

module.exports = spawnSelenium
