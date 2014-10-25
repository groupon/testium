
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
var existsSync, getFile, path, uniqueFile, writeFileSync, _ref;

path = require('path');

_ref = require('fs'), writeFileSync = _ref.writeFileSync, existsSync = _ref.existsSync;

module.exports = function(directory, title, data, encoding) {
  var file;
  if (encoding == null) {
    encoding = 'base64';
  }
  file = getFile(directory, title);
  writeFileSync(file, data, encoding);
  return file;
};

getFile = function(directory, title) {
  var filePath, name;
  name = title.replace(/[^\w]/g, '_').replace(/_{2,}/g, '_').substr(0, 40);
  filePath = path.join(directory, name);
  return uniqueFile(filePath);
};

uniqueFile = function(file) {
  var counter, testPath;
  testPath = file;
  counter = null;
  while (existsSync("" + testPath + ".png")) {
    counter || (counter = 0);
    counter++;
    testPath = "" + file + counter;
  }
  return "" + testPath + ".png";
};
