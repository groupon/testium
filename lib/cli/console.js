
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
var Module, WELCOME_MESSAGE, collectPublicMethods, collectPublicMethodsDeep, config, exportToContext, getBrowser, getMethods, path;

WELCOME_MESSAGE = "WebDriver repl!\nMethods are available in scope. Try: navigateTo('google.com')\nType `.methods` to see what's available.";

Module = require('module');

path = require('path');

config = require('../config');

getBrowser = require('../testium').getBrowser;

collectPublicMethods = function(obj) {
  var method, methods, prop;
  methods = [];
  for (prop in obj) {
    method = obj[prop];
    if (typeof method === 'function' && prop[0] !== '_') {
      methods.push(prop);
    }
  }
  return methods;
};

collectPublicMethodsDeep = function(obj) {
  var proto;
  if (obj == null) {
    return [];
  }
  proto = Object.getPrototypeOf(obj);
  return collectPublicMethods(obj).concat(collectPublicMethodsDeep(proto));
};

getMethods = function(browser) {
  var methods;
  methods = collectPublicMethodsDeep(browser);
  return methods.sort().join(', ');
};

exportToContext = function(browser, context) {
  var methods;
  context.browser = browser;
  context.assert = browser.assert;
  methods = collectPublicMethodsDeep(browser);
  return methods.forEach(function(method) {
    return context[method] = browser[method].bind(browser);
  });
};

module.exports = function() {
  var Repl, browserName, pretendFilename, replModule;
  browserName = config.browser;
  console.error("Preparing " + browserName + "...");
  pretendFilename = path.resolve(config.root, 'repl');
  replModule = Module._resolveFilename(config.repl.module, {
    filename: pretendFilename,
    paths: Module._nodeModulePaths(pretendFilename)
  }, false);
  Repl = require(replModule);
  return getBrowser(function(error, browser) {
    var closeBrowser, startRepl;
    if (error != null) {
      throw error;
    }
    closeBrowser = function() {
      return browser.close(function(error) {
        if (error == null) {
          return;
        }
        error.message = "" + error.message + " (while closing browser)";
        throw error;
      });
    };
    startRepl = function() {
      var repl;
      repl = Repl.start({
        prompt: "" + browserName + "> "
      });
      exportToContext(browser, repl.context);
      repl.on('exit', function() {
        return browser.close(function() {
          return process.exit(0);
        });
      });
      return repl.defineCommand('methods', {
        help: 'List available methods',
        action: function() {
          repl.outputStream.write(getMethods(browser));
          return repl.displayPrompt();
        }
      });
    };
    process.on('exit', closeBrowser);
    process.on('uncaughtException', function(error) {
      closeBrowser();
      throw error;
    });
    console.error(WELCOME_MESSAGE);
    return startRepl(browser);
  });
};
