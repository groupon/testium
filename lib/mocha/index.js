
/*
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
 */
var BETTER_TITLE, CLOSE_BROWSER, CLOSE_BROWSER_PATTERN, DEFAULT_TITLE, addCloseBrowserHook, closeBrowser, config, debug, deepMochaTimeouts, getBrowser, getRootSuite, injectBrowser, isCloseBrowserHook, path, setMochaTimeouts, takeScreenshotOnFailure;

path = require('path');

debug = require('debug')('testium:mocha');

config = require('../config');

getBrowser = require('../testium').getBrowser;

takeScreenshotOnFailure = require('./screenshot');

setMochaTimeouts = function(obj) {
  obj.timeout(+config.mocha.timeout);
  return obj.slow(+config.mocha.slow);
};

deepMochaTimeouts = function(suite) {
  setMochaTimeouts(suite);
  suite.suites.forEach(deepMochaTimeouts);
  suite.tests.forEach(setMochaTimeouts);
  suite._beforeEach.forEach(setMochaTimeouts);
  suite._beforeAll.forEach(setMochaTimeouts);
  suite._afterEach.forEach(setMochaTimeouts);
  return suite._afterAll.forEach(setMochaTimeouts);
};

closeBrowser = function(browser) {
  return function(done) {
    return browser.close(function(error) {
      if (error == null) {
        return done();
      }
      error.message = "" + error.message + " (while closing browser)";
      return done(error);
    });
  };
};

CLOSE_BROWSER = 'closeBrowser';

CLOSE_BROWSER_PATTERN = /hook: closeBrowser$/;

isCloseBrowserHook = function(hook) {
  return CLOSE_BROWSER_PATTERN.test(hook.title);
};

addCloseBrowserHook = function(suite, browser) {
  if (suite._afterAll.some(isCloseBrowserHook)) {
    return;
  }
  return suite.afterAll(CLOSE_BROWSER, closeBrowser(browser));
};

getRootSuite = function(suite) {
  if (suite.parent) {
    return getRootSuite(suite.parent);
  } else {
    return suite;
  }
};

DEFAULT_TITLE = '"before all" hook';

BETTER_TITLE = '"before all" hook: Testium setup hook';

injectBrowser = function(options) {
  if (options == null) {
    options = {};
  }
  return function(done) {
    var initialTimeout, reuseSession, suite;
    if (this._runnable.title === DEFAULT_TITLE) {
      this._runnable.title = BETTER_TITLE;
    }
    debug('Overriding mocha timeouts', config.mocha);
    suite = this._runnable.parent;
    deepMochaTimeouts(suite);
    initialTimeout = +config.app.timeout;
    initialTimeout += +config.mocha.timeout;
    this.timeout(initialTimeout);
    reuseSession = options.reuseSession != null ? options.reuseSession : options.reuseSession = true;
    return getBrowser(options, (function(_this) {
      return function(err, browser) {
        var afterEachHook, browserScopeSuite, screenshotDirectory;
        _this.browser = browser;
        if (err != null) {
          return done(err);
        }
        screenshotDirectory = config.screenshotDirectory;
        if (screenshotDirectory) {
          screenshotDirectory = path.resolve(config.root, screenshotDirectory);
          afterEachHook = takeScreenshotOnFailure(screenshotDirectory);
          suite.afterEach('takeScreenshotOnFailure', afterEachHook);
        }
        browserScopeSuite = reuseSession ? getRootSuite(suite) : suite;
        addCloseBrowserHook(browserScopeSuite, browser);
        return done();
      };
    })(this));
  };
};

module.exports = injectBrowser;
