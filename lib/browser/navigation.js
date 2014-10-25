
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
var NavigationMixin, defaults, hasType, isObject, makeUrlRegExp, omit, qs, urlParse, waitFor, _ref;

urlParse = require('url').parse;

qs = require('querystring');

hasType = require('assertive').hasType;

_ref = require('lodash'), omit = _ref.omit, defaults = _ref.defaults, isObject = _ref.isObject;

waitFor = require('./wait');

makeUrlRegExp = require('./makeUrlRegExp');

NavigationMixin = {
  navigateTo: function(url, options) {
    var currentUrl, hasProtocol, query, sep;
    if (options == null) {
      options = {};
    }
    hasType('navigateTo(url) - requires (String) url', String, url);
    query = options.query;
    if (query != null) {
      hasType('navigateTo(url, {query}) - query must be an Object, if provided', Object, query);
      sep = /\?/.test(url) ? '&' : '?';
      url += sep + qs.encode(query);
    }
    options = defaults({
      url: url
    }, omit(options, 'query'));
    hasProtocol = /^[^:\/?#]+:\/\//;
    if (!hasProtocol.test(url)) {
      url = "" + this.proxyUrl + url;
    }
    this.driver.http.post("" + this.commandUrl + "/new-page", options);
    currentUrl = this.driver.getUrl();
    if (currentUrl === url) {
      this.driver.refresh();
    } else {
      this.driver.navigateTo(url);
    }
    return this.driver.rootWindow = this.driver.getCurrentWindowHandle();
  },
  refresh: function() {
    return this.driver.refresh();
  },
  getUrl: function() {
    return this.driver.getUrl();
  },
  getPath: function() {
    var url;
    url = this.driver.getUrl();
    return urlParse(url).path;
  },
  waitForUrl: function(url, query, timeout) {
    if (typeof query === 'number') {
      timeout = query;
    } else if (isObject(query)) {
      url = makeUrlRegExp(url, query);
    }
    return waitFor(url, 'Url', ((function(_this) {
      return function() {
        return _this.driver.getUrl();
      };
    })(this)), timeout != null ? timeout : 5000);
  },
  waitForPath: function(url, timeout) {
    if (timeout == null) {
      timeout = 5000;
    }
    return waitFor(url, 'Path', ((function(_this) {
      return function() {
        return _this.getPath();
      };
    })(this)), timeout);
  }
};

module.exports = NavigationMixin;
