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

wd = require 'wd'
{find, each} = require 'lodash'
assert = require 'assertive'
Hub = require 'gofer/hub'

{tryParse} = require '../browser/json'

decode = (value) ->
  (new Buffer value, 'base64').toString('utf8')

parseTestiumCookie = (cookie) ->
  value = decode(cookie.value)
  tryParse(value)

getTestiumCookie = (cookies) ->
  testiumCookie = find cookies, name: '_testium_'

  unless testiumCookie?
    throw new Error 'Unable to communicate with internal proxy. Make sure you are using relative paths.'

  parseTestiumCookie(testiumCookie)

CookieMixin =
  _getTestiumCookieField: (name) ->
    @allCookies()
      .then getTestiumCookie
      .then (testiumCookie) -> testiumCookie?[name]

  getStatusCode: ->
    @_getTestiumCookieField 'statusCode'

  assertStatusCode: (status) ->
    @getStatusCode()
      .then (actual) -> assert.equal status, actual

module.exports = createBrowser = (options, cb) ->
  {targetUrl, commandUrl} = options.proxy ? {}

  hub = new Hub()

  wd.addPromiseChainMethod '_sendTestiumCommand', (pathname, json) ->
    hub.fetch({ method: 'POST', uri: "#{commandUrl}#{pathname}", json }).then()


  each CookieMixin, (method, name) ->
    wd.addPromiseChainMethod name, method


  wd.addPromiseChainMethod 'assertElementHasText', (selector, text) ->
    # do stuff
    throw new Error 'Not implemented (assertElementHasText)'


  # TODO: Add, extract, remove from PromiseChainWebdriver
  #       to get the wrapper and not pollute wd globally
  wd.addPromiseChainMethod 'navigateTo', (url, options = {}) ->
    # TODO: handle query string etc.
    @_sendTestiumCommand '/new-page', {url}
      .get url


  { driverType, desiredCapabilities, selenium: { driverUrl } } = options
  browser = wd.remote driverUrl, driverType
  browser.configureHttp baseUrl: targetUrl

  browser.init(desiredCapabilities)
    .navigateTo '/testium-priming-load'
    .then -> browser
    .nodeify cb
