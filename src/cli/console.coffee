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

WELCOME_MESSAGE = """
WebDriver repl!
Methods are available in scope. Try: navigateTo('http://google.com')
Type `.methods` to see what's available.
"""

{_resolveFilename, _nodeModulePaths} = require 'module'
path = require 'path'

{getConfig, getBrowser} = require 'testium-core'

config = getConfig()

collectPublicMethods = (obj) ->
  methods = []
  for prop, method of obj
    if typeof method == 'function' && prop[0] != '_'
      methods.push(prop)
  methods

collectPublicMethodsDeep = (obj) ->
  return [] unless obj?
  proto = Object.getPrototypeOf(obj)
  collectPublicMethods(obj).concat(
    collectPublicMethodsDeep(proto)
  )

getMethods = (browser) ->
  methods = collectPublicMethodsDeep browser
  methods.sort().join(', ')

exportToContext = (browser, context) ->
  context.browser = browser
  context.assert = browser.assert
  methods = collectPublicMethodsDeep browser
  methods.forEach (method) ->
    context[method] = browser[method].bind(browser)

prepareRequireExtensions = (pretendModule, replModule) ->
  # This hack allows using mixins written in coffee-script
  # It won't actually change anything in terms of require extensions
  # since the coffee-script repl will register the extension anyhow.
  REDUX = /coffee-script-redux(?:\/lib)?\/repl(?:\.js)?$/
  if REDUX.test(replModule)
    coffeeModule =
      _resolveFilename 'coffee-script-redux/register', pretendModule, false
    require coffeeModule

  COFFEE = /coffee-script(?:\/lib)?\/repl(?:\.js)?$/
  if COFFEE.test(replModule)
    coffeeModule =
      _resolveFilename 'coffee-script/register', pretendModule, false
    require coffeeModule

module.exports = ->
  browserName = config.browser
  console.error "Preparing #{browserName}..."

  # Hack for resolving modules correctly relative to appDirectory
  pretendFilename = path.resolve config.root, 'repl'
  pretendModule = {
    filename: pretendFilename
    paths: _nodeModulePaths pretendFilename
  }

  replModule = _resolveFilename config.repl.module, pretendModule, false

  prepareRequireExtensions pretendModule, replModule

  Repl = require replModule

  getBrowser(useApp: false).done (browser) ->
    closeBrowser = ->
      browser.close (error) ->
        return unless error?
        error.message = "#{error.message} (while closing browser)"
        throw error

    startRepl = ->
      repl = Repl.start {
        prompt: "#{browserName}> "
      }
      exportToContext browser, repl.context
      repl.on 'exit', ->
        browser.close -> process.exit(0)
      repl.defineCommand 'methods', {
        help: 'List available methods'
        action: ->
          repl.outputStream.write getMethods browser
          repl.displayPrompt()
      }

    process.on 'exit', closeBrowser
    process.on 'uncaughtException', (error) ->
      closeBrowser()
      throw error

    console.error WELCOME_MESSAGE
    startRepl browser
