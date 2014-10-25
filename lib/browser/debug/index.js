
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
var DebugMixin, TYPES, assert, cachedLogs, filterLogs, parseLogs, _ref;

assert = require('assertive');

_ref = require('./console'), parseLogs = _ref.parseLogs, filterLogs = _ref.filterLogs;

TYPES = ['error', 'warn', 'log', 'debug'];

cachedLogs = [];

DebugMixin = {
  getConsoleLogs: function(type) {
    var logs, matched, newLogs, rest, _ref1;
    if (type != null) {
      assert.include(type, TYPES);
    }
    newLogs = parseLogs(this.driver.getConsoleLogs());
    logs = cachedLogs.concat(newLogs);
    _ref1 = filterLogs(logs, type), matched = _ref1.matched, rest = _ref1.rest;
    cachedLogs = rest || [];
    return matched || [];
  }
};

module.exports = DebugMixin;
