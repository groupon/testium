
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
var Assertions, Browser, debug, extend, hasType, patchCapabilities, truthy, _ref,
  __slice = [].slice;

extend = require('lodash').extend;

_ref = require('assertive'), truthy = _ref.truthy, hasType = _ref.hasType;

debug = require('debug')('testium:browser');

Assertions = require('../assert');

patchCapabilities = require('./capabilities');

Browser = (function() {
  function Browser(driver, proxyUrl, commandUrl) {
    var invocation;
    this.driver = driver;
    this.proxyUrl = proxyUrl;
    this.commandUrl = commandUrl;
    invocation = 'new Browser(driver, proxyUrl, commandUrl)';
    hasType("" + invocation + " - requires (Object) driver", Object, driver);
    hasType("" + invocation + " - requires (String) proxyUrl", String, proxyUrl);
    hasType("" + invocation + " - requires (String) commandUrl", String, commandUrl);
    this.assert = new Assertions(this.driver, this);
  }

  Browser.prototype.init = function(_arg) {
    var keepCookies, skipPriming, _ref1;
    _ref1 = _arg != null ? _arg : {}, skipPriming = _ref1.skipPriming, keepCookies = _ref1.keepCookies;
    if (skipPriming) {
      debug('Skipping priming load');
    } else {
      this.navigateTo('/testium-priming-load');
      debug('Browser was primed');
    }
    if (keepCookies) {
      debug('Keeping cookies around');
    } else {
      debug('Clearing cookies for clean state');
      this.clearCookies();
    }
    return this.setPageSize({
      height: 768,
      width: 1024
    });
  };

  Browser.prototype.close = function(callback) {
    var error;
    hasType('close(callback) - requires (Function) callback', Function, callback);
    try {
      this.driver.close();
      return callback();
    } catch (_error) {
      error = _error;
      return callback(error);
    }
  };

  Browser.prototype.evaluate = function(clientFunction) {
    var args, invocation, _i;
    if (arguments.length > 1) {
      args = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), clientFunction = arguments[_i++];
    }
    invocation = 'evaluate(clientFunction) - requires (Function|String) clientFunction';
    truthy(invocation, clientFunction);
    if (typeof clientFunction === 'function') {
      args = JSON.stringify(args != null ? args : []);
      clientFunction = "return (" + clientFunction + ").apply(this, " + args + ");";
    } else if (typeof clientFunction !== 'string') {
      throw new Error(invocation);
    }
    return this.driver.evaluate(clientFunction);
  };

  return Browser;

})();

Object.defineProperty(Browser.prototype, 'capabilities', {
  get: function() {
    return patchCapabilities(this.driver.capabilities);
  }
});

[require('./alert'), require('./cookie'), require('./debug'), require('./element'), require('./input'), require('./navigation'), require('./page'), require('./window')].forEach(function(mixin) {
  return extend(Browser.prototype, mixin);
});

module.exports = Browser;
