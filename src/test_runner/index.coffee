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

Mocha = require 'mocha'
path = require 'path'
store = require '../test_setup/store'
files = require './files'
{compact, extend} = require 'underscore'

require('coffee-script-redux/register')

passValuesToTestiumBeforeTestFiles = (options) ->
  store.set
    logDirectory: options.logDirectory
    http: options.http
    browser: options.browser
    screenshotDirectory: options.screenshotDirectory
    seleniumServer: options.seleniumServer

validateBrowser = (browser) ->
  return browser if browser in ['phantomjs', 'firefox', 'chrome']
  return 'phantomjs' if !browser?

  throw new Error "Browser not supported by Testium: #{browser}"

process.on 'message', (options) ->
  options.browser = validateBrowser(options.browser)
  passValuesToTestiumBeforeTestFiles(options)

  {tests, beforeTests, mochaOptions, appDirectory} = options
  mochaOptions ?= {}

  if !tests?
    console.error 'Must specify tests to run!'
    process.exit(-1)

  runMocha = (testFiles) ->
    defaults =
      reporter: 'spec'
      timeout: 20000
    options = extend {}, defaults, mochaOptions
    mocha = new Mocha(options)

    testFiles.forEach (file) ->
      mocha.addFile file

    mocha.run (failures) ->
      global.exitMocha ->
        process.exit(failures)

  testiumBeforeTestFiles = ["#{__dirname}/../test_setup/index.js"]
  beforeTestFiles = files.findAll(beforeTests, appDirectory)
  testFiles = files.findAll(tests, appDirectory)
  allTestFiles = compact(testiumBeforeTestFiles.concat(beforeTestFiles).concat(testFiles))

  runMocha(allTestFiles)
