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

browserName = process.argv[2] || 'firefox'
logDirectory = "#{__dirname}/../log"
store = require './test_setup/store'
store.set
  logDirectory: logDirectory
  browser: browserName
  screenshotDirectory: "#{logDirectory}/screenshots"
  seleniumServer: 'http://localhost:4444/wd/hub'

csrepl = require 'coffee-script-redux/lib/repl'
selenium = require './selenium'
{extend} = require 'underscore'
{getBrowser} = require './test_setup/browser'

WELCOME_MESSAGE = """
WebDriver repl!
Methods are available in scope. Try: navigateTo 'google.com'
Type `methods` to see what's available.
"""

normalize = (url) ->
  if url.indexOf('http') == -1
    "http://#{url}"
  else
    url

createBrowser = ->
  browser = getBrowser()
  _navigateTo = browser.navigateTo

  browser.navigateTo = (url, options) ->
    url = normalize(url)
    _navigateTo.call(browser, url, options)

  browser

selenium.start null, null, logDirectory, 80, (error) ->
  throw error if error?

  require 'coffee-script-redux/register'

  console.log WELCOME_MESSAGE
  cli = csrepl.start { prompt: '%> ' }
  cli.on 'exit', (exitCode) ->
    browser.close ->
      selenium.cleanup ->
        process.exit(exitCode)

  browser = createBrowser()
  extend cli.context, browser
  cli.context.methods = getMethods(browser)

getMethods = (browser) ->
  properties = Object.keys browser
  methods = []
  for prop in properties
    if typeof browser[prop] == 'function'
      methods.push(prop)
  methods.sort().join(', ')

process.on 'unhandledException', ->
  selenium.cleanup ->
    process.exit(1)

