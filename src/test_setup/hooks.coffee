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

{takeScreenshotOnFailure} = require './screenshot'
{getBrowser} = require './browser'
store = require './store'

exit = (done) ->
  selenium.cleanup ->
    if browser?
      browser.close(done)
      browser = undefined
    else
      done()

selenium = require '../selenium'
startSelenium = ({seleniumServer, javaHeapSize, logDirectory, applicationPort}, callback) ->
  if seleniumServer
    selenium.start seleniumServer, javaHeapSize, logDirectory, applicationPort, callback
  else
    binPath = "#{__dirname}/../bin"
    selenium.ensure binPath, (error) ->
      return callback(error) if error?
      selenium.start null, javaHeapSize, logDirectory, applicationPort, callback


beforeAll = (options) ->
  (done) ->
    startSelenium options, (error, serverUrl) ->
      return done(error) if error?

      store.set {seleniumServer: serverUrl}

      # first page load is guranteed
      # by the proxy to be a success
      # this allows us to set cookies
      # right away in tests
      browser = getBrowser()
      browser.navigateTo '/testium-priming-load'

      done()

afterAll = (done) ->
  exit(done)

afterEach = (screenshotDirectory) ->
  ->
    browser = getBrowser()
    takeScreenshotOnFailure(screenshotDirectory, @currentTest, browser)

module.exports = { beforeAll, afterAll, afterEach, exit }

