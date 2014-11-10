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

{extend} = require 'lodash'
{truthy, hasType} = require 'assertive'
debug = require('debug')('testium:browser')

Assertions = require '../assert'
patchCapabilities = require './capabilities'

class Browser
  constructor: (@driver, @proxyUrl, @commandUrl) ->
    invocation = 'new Browser(driver, proxyUrl, commandUrl)'
    hasType "#{invocation} - requires (Object) driver", Object, driver
    hasType "#{invocation} - requires (String) proxyUrl", String, proxyUrl
    hasType "#{invocation} - requires (String) commandUrl", String, commandUrl
    @assert = new Assertions @driver, this

  init: ({skipPriming, keepCookies} = {}) ->
    if skipPriming
      debug 'Skipping priming load'
    else
      @navigateTo '/testium-priming-load'
      debug 'Browser was primed'
    
    if keepCookies
      debug 'Keeping cookies around'
    else
      debug 'Clearing cookies for clean state'
      @clearCookies()

    # default to reasonable size
    # fixes some phantomjs element size/position reporting
    @setPageSize { height: 768, width: 1024 }

  close: (callback) ->
    hasType 'close(callback) - requires (Function) callback', Function, callback

    try
      @driver.close()
      callback()
    catch error
      return callback error

  evaluate: (clientFunction) ->
    if arguments.length > 1
      [args..., clientFunction] = arguments

    invocation = 'evaluate(clientFunction) - requires (Function|String) clientFunction'
    truthy invocation, clientFunction
    if typeof clientFunction == 'function'
      args = JSON.stringify(args ? [])
      clientFunction = "return (#{clientFunction}).apply(this, #{args});"
    else if typeof clientFunction != 'string'
      throw new Error invocation

    @driver.evaluate(clientFunction)

Object.defineProperty Browser.prototype, 'capabilities', {
  get: ->
    patchCapabilities @driver.capabilities
}

[
  require('./alert')
  require('./cookie')
  require('./debug')
  require('./element')
  require('./input')
  require('./navigation')
  require('./page')
  require('./window')
].forEach (mixin) ->
  extend Browser.prototype, mixin

module.exports = Browser
