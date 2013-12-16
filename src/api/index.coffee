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

WebDriver = require 'webdriver-http-sync'
log = require '../log'
{truthy} = require 'assertive'
{extend} = require 'underscore'

createAlertApi = require './alert'
createAssertApi = require './assert'
createElementApi = require './element'
createNavigationApi = require './navigation'
createPageApi = require './page'
createInputApi = require './input'
createCookieApi = require './cookie'

module.exports = class
  constructor: (targetPort, proxyCommandPort, desiredCapabilities, options={}) ->
    invocation = 'new DSL(targetPort, proxyCommandPort, desiredCapabilities)'
    truthy "#{invocation} - requires targetPort", targetPort
    truthy "#{invocation} - requires proxyCommandPort", proxyCommandPort
    truthy "#{invocation} - requires desiredCapabilities", desiredCapabilities

    @proxyCommandRoot = "http://127.0.0.1:#{proxyCommandPort}"
    @urlRoot = "http://127.0.0.1:#{targetPort}"
    @log = log(options.logDirectory)

    @driver = new WebDriver(desiredCapabilities, options.http)
    @driver.on 'request', @log
    @driver.on 'response', @log.response

    @alert = createAlertApi(@driver)
    @assert = createAssertApi(@driver)

    extend this, createNavigationApi(@driver)
    extend this, createPageApi(@driver)
    extend this, createElementApi(@driver)
    extend this, createInputApi(@driver)
    extend this, createCookieApi(@driver)

  close: (callback) ->
    truthy 'close(callback) - requires callback', callback

    @driver.close()
    @log.flush(callback)

  evaluate: (clientFunction) ->
    if arguments.length > 1
      [args..., clientFunction] = arguments

    truthy 'evaluate(clientFunction) - requires clientFunction', clientFunction
    if typeof clientFunction is 'function'
      args = JSON.stringify(args ? [])
      clientFunction = "return (#{clientFunction}).apply(this, #{args});"

    @driver.evaluate(clientFunction)

