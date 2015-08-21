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

assert = require 'assertive'
debug = require('debug')('testium:testium')
{merge} = require 'lodash'

config = require './config'
Browser = require './browser'
Assertions = require './assert'
processes = require('./processes')()
createBrowser = require './drivers'

RESOURCE_TIMEOUT = 'phantomjs.page.settings.resourceTimeout'
ensureDesiredCapabilities = (config) ->
  capabilities = config.desiredCapabilities ? {}
  capabilities.browserName ?= config.browser
  switch capabilities.browserName
    when 'phantomjs'
      capabilities[RESOURCE_TIMEOUT] ?= 2500

  config.desiredCapabilities = capabilities

getBrowser = (options, done) ->
  if typeof options == 'function'
    done = options
    options = {}

  assert.hasType '''
    getBrowser requires a callback, please check the docs for breaking changes
  ''', Function, done

  ensureDesiredCapabilities config

  processes.ensureRunning config, (err, results) =>
    return done(err) if err?
    {selenium, proxy, application} = results

    completeConfig = merge {
      reuseSession: true
      keepCookies: false
      useApp: config.app?
      driverType: 'sync'
      app:
        baseUrl: application?.baseUrl
      proxy:
        targetUrl: proxy?.baseUrl
        commandUrl: proxy?.commandUrl
      selenium:
        driverUrl: selenium.driverUrl
    }, config, options

    createBrowser completeConfig, done

exports.getBrowser = getBrowser
exports.Browser = Browser
exports.Assertions = Assertions
