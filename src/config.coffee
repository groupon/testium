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

rc = require 'rc'

getDefaults = ->
  # Root directory of the application.
  # All paths will be resolved relative to this directory.
  # It's also where testium will look for a `package.json` file
  # to figure out how to start the app.
  root: process.cwd()
  # Automatically launch the app with NODE_ENV=test.
  # Set this to true if you want testium to handle this for you
  # when you call `getBrowser`.
  launch: false

  # The browser to use, possible values:
  # phantomjs | chrome | firefox | internet explorer
  browser: 'phantomjs'
  desiredCapabilities: {}

  # Directory (relative to `root`) where logs are written by testium
  logDirectory: './test/log'
  # Directory to store automated screenshosts, e.g. on failing tests
  screenshotDirectory: './test/log/failed_screenshots'

  # Options for web driver connections
  # can specify timeout and connectTimeout here, defaults are
  # connectTimeout = 2000
  # timeout = 60000
  webdriver:
    requestOptions: {}

  app:
    # A port of 0 means "auto-select available port"
    port: process.env.PORT || 0
    # How long to wait for the app to start listening
    timeout: 30000
    # Command to start the app.
    # `null` means testium will simulate `npm start`
    command: null
  phantomjs:
    # Command to start phantomjs
    # Change this if you don't have phantomjs in your PATH
    command: 'phantomjs'
    # How long to wait for phantomjs to listen
    timeout: 6000
  selenium:
    # How long to wait for selenium to listen
    timeout: 90000
    # Set this if you have a running selenium server
    # and don't want testium to start one.
    serverUrl: null
    # Path to selenium jar.
    # `null` means "use testium built-in".
    # Using the testium built-in binaries requires you to run
    # `testium --download-selenium` before running your tests.
    jar: null
    # Path to chromedriver.
    # `null` means "use testium built-in", see `jar` above.
    chromedriver: null
  repl:
    # Module for the testium repl
    # If you want to use coffee-script in the repl, use:
    # * `module: coffee-script/repl` for coffee-script
    # * `module: coffee-script-redux/lib/repl` for redux
    module: 'repl'
  mixins:
    # mixin modules allow you to add new methods to the browser
    # Example:
    # ```
    # module.exports = {
    #   // available as `browser.goHome()`
    #   goHome: function() {
    #     this.click('header #home');
    #   }
    # };
    # ```
    # Elements in the array should be node.js module names
    # that can be required relative to `root`.
    browser: []
    # Same as browser, only that it extends `browser.assert`.
    # Use this.browser to access the browser.
    assert: []
  mocha:
    # mocha timeout for all tests that are in the suite the
    # browser was injected into.
    timeout: 20000
    # Same, just for `slow`.
    slow: 2000

module.exports = rc 'testium', getDefaults()
