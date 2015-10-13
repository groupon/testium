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
{each, extend, once} = require 'lodash'
initTestium = require 'testium-core'
createDriver = require 'testium-driver-sync'

initTestiumOnce = once initTestium

applyMixin = (obj, mixin) ->
  extend obj, mixin

applyMixins = (obj, mixins = []) ->
  each mixins, (mixin) ->
    debug 'Applying mixin to %s', obj.constructor.name, mixin
    mixinFile = path.resolve process.cwd(), mixin
    applyMixin obj, require mixinFile

cachedDriver = null

getTestium = (options) ->
  reuseSession = options.reuseSession ? true
  # TODO: Figure this part out & honor keepCookies
  keepCookies = options.keepCookies ? false

  browserName = 'phantomjs' # start with a guess
  createCachedDriver = (testium) ->
    browserName = testium.config.get('browser')

    if reuseSession
      cachedDriver ?= createDriver testium
    else
      createDriver testium

  generateDriverError = (error) ->
    logName =
      if browserName == 'phantomjs'
        'phantomjs.log'
      else
        'selenium.log'
    error.message =
      """
      Failed to initialize WebDriver. Check the #{logName}.
      #{error.message}
      """
    throw error

  addBrowserWithMixins = (testium) ->
    {browser, config} = testium
    applyMixins browser, config.get('mixins.browser', [])
    applyMixins browser.assert, config.get('mixins.assert', [])

    testium

  initTestiumOnce()
    .then createCachedDriver
    .catch generateDriverError
    .then addBrowserWithMixins

getBrowser = (options, callback) ->
  if typeof options == 'function'
    done = options
    options = {}

  assert.hasType '''
    getBrowser requires a callback, please check the docs for breaking changes
  ''', Function, done

  getTestium(options)
    .then ({browser}) -> browser
    .nodeify callback

exports.getBrowser = getBrowser
exports.getTestium = getTestium
