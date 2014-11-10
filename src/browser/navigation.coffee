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

{parse: urlParse} = require 'url'
qs = require 'querystring'

{hasType} = require 'assertive'
{omit, defaults, isObject} = require 'lodash'

waitFor = require './wait'
makeUrlRegExp = require './makeUrlRegExp'

NavigationMixin =
  navigateTo: (url, options = {}) ->
    hasType 'navigateTo(url) - requires (String) url', String, url
    {query} = options
    if query?
      hasType '''
        navigateTo(url, {query}) - query must be an Object, if provided
      ''', Object, query
      sep = if /\?/.test url then '&' else '?'
      url += sep + qs.encode query

    options = defaults {url}, omit(options, 'query')

    hasProtocol = /^[^:\/?#]+:\/\//
    unless hasProtocol.test url
      url = "#{@proxyUrl}#{url}"

    @driver.http.post "#{@commandUrl}/new-page", options

    # WebDriver does nothing if currentUrl is the same as targetUrl
    currentUrl = @driver.getUrl()
    if currentUrl == url
      @driver.refresh()
    else
      @driver.navigateTo(url)

    # Save the window handle for referencing later
    # in `switchToDefaultWindow`
    @driver.rootWindow = @driver.getCurrentWindowHandle()

  refresh: ->
    @driver.refresh()

  getUrl: ->
    @driver.getUrl()

  getPath: ->
    url = @driver.getUrl()
    urlParse(url).path

  waitForUrl: (url, query, timeout) ->
    if typeof query is 'number'
      timeout = query
    else if isObject query
      url = makeUrlRegExp url, query
    waitFor(url, 'Url', (=> @driver.getUrl()), timeout ? 5000)

  waitForPath: (url, timeout=5000) ->
    waitFor(url, 'Path', (=> @getPath()), timeout)

module.exports = NavigationMixin
