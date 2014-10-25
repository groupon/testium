
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
var buildCookie, encode;

encode = function(string) {
  return (new Buffer(string)).toString('base64');
};

buildCookie = function(headers, statusCode) {
  var encodedData;
  encodedData = {
    headers: headers,
    statusCode: statusCode
  };
  encodedData = JSON.stringify(encodedData);
  encodedData = encode(encodedData);
  return "_testium_=" + encodedData + "; path=/";
};

module.exports = function(response) {
  var type;
  if (response.headers == null) {
    response.headers = {};
  }
  type = response.headers["content-type"];
  if (response.headers["Set-Cookie"]) {
    console.log("Existing Set-Cookie Header!! " + response.headers["Set-Cookie"]);
  }
  response.headers['Cache-Control'] = 'no-store';
  response.headers["Set-Cookie"] = buildCookie(response.headers, response.statusCode);
  if (response.statusCode >= 400) {
    console.log("<-- forcing status code from " + response.statusCode + " to 200");
    response.statusCode = 200;
  }
  return console.log("<-- Set-Cookie: " + response.headers["Set-Cookie"]);
};
