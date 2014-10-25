
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
var buildRemoteRequestOptions, commandError, concat, emptySuccess, firstPage, http, isNewPage, markNewPage, markRequestClosed, modifyRequest, newPageOptions, normalizeOptions, openRequests, proxyCommand, proxyRequest, trimHash, url;

http = require('http');

url = require('url');

concat = require('concat-stream');

buildRemoteRequestOptions = function(request, toPort) {
  var opt, uri;
  uri = url.parse(request.url);
  opt = {
    port: toPort,
    path: uri.path,
    method: request.method,
    headers: request.headers
  };
  opt.headers['connection'] = 'keep-alive';
  opt.headers['cache-control'] = 'no-store';
  delete opt.headers['if-none-match'];
  delete opt.headers['if-modified-since'];
  return opt;
};

trimHash = function(url) {
  return url.split('#')[0];
};

normalizeOptions = function(options) {
  options.url = trimHash(options.url);
  return options;
};

openRequests = [];

firstPage = true;

newPageOptions = {};

markNewPage = function(options, response) {
  var request, _i, _len;
  newPageOptions = normalizeOptions(options);
  console.log("\n[System] Marking new page request with options: " + (JSON.stringify(newPageOptions)));
  for (_i = 0, _len = openRequests.length; _i < _len; _i++) {
    request = openRequests[_i];
    console.log('[System] Aborting request for: ' + request.path);
    request.aborted = true;
    request.abort();
  }
  openRequests = [];
  return response.end();
};

isNewPage = function(url) {
  return url === newPageOptions.url;
};

markRequestClosed = function(targetRequest) {
  return openRequests = openRequests.filter(function(request) {
    return request !== targetRequest;
  });
};

commandError = function(url, response) {
  console.log("[System] Unknown command: " + url);
  response.statusCode = 500;
  response.writeHead(response.statusCode, response.headers);
  return response.end();
};

emptySuccess = function(response) {
  response.writeHead(200, {
    'Content-Type': 'text/html'
  });
  return response.end();
};

proxyCommand = function(url, body, response) {
  switch (url) {
    case '/new-page':
      return markNewPage(body, response);
    default:
      return commandError(url, response);
  }
};

modifyRequest = function(request, options) {
  var header, value, _ref, _results;
  if (options.headers == null) {
    return;
  }
  _ref = options.headers;
  _results = [];
  for (header in _ref) {
    value = _ref[header];
    _results.push(request.headers[header] = value);
  }
  return _results;
};

proxyRequest = function(request, response, modifyResponse, toPort) {
  var remoteRequest, remoteRequestOptions;
  if (firstPage || request.url === '/testium-priming-load') {
    firstPage = false;
    console.log("--> " + request.method + " " + request.url + " (prime the browser)");
    return emptySuccess(response);
  }
  console.log("--> " + request.method + " " + request.url);
  remoteRequestOptions = buildRemoteRequestOptions(request, toPort);
  console.log("    " + (JSON.stringify(remoteRequestOptions)));
  if (isNewPage(request.url)) {
    modifyRequest(remoteRequestOptions, newPageOptions);
  }
  remoteRequest = http.request(remoteRequestOptions, function(remoteResponse) {
    markRequestClosed(remoteRequest);
    if (isNewPage(request.url)) {
      modifyResponse(remoteResponse);
    }
    response.writeHead(remoteResponse.statusCode, remoteResponse.headers);
    remoteResponse.on('end', function() {
      return console.log("<-- " + response.statusCode + " " + request.url);
    });
    return remoteResponse.pipe(response);
  });
  remoteRequest.on('error', function(error) {
    response.statusCode = 500;
    markRequestClosed(remoteRequest);
    if (isNewPage(request.url)) {
      modifyResponse(response);
    }
    console.log(error.stack);
    console.log('<-- ' + response.statusCode + ' ' + request.url);
    response.writeHead(response.statusCode, response.headers);
    return response.end();
  });
  openRequests.push(remoteRequest);
  request.pipe(remoteRequest);
  return request.on('end', function() {
    return remoteRequest.end();
  });
};

module.exports = function(fromPort, toPort, commandPort, modifyResponse) {
  var commandServer, server;
  server = http.createServer(function(request, response) {
    return proxyRequest(request, response, modifyResponse, toPort);
  });
  server.listen(fromPort);
  console.log("Listening on port " + fromPort + " and proxying to " + toPort + ".");
  commandServer = http.createServer(function(request, response) {
    return request.pipe(concat(function(body) {
      var options;
      if (body != null) {
        options = JSON.parse(body.toString());
      }
      return proxyCommand(request.url, options, response);
    }));
  });
  commandServer.listen(commandPort);
  return console.log("Listening for commands on port " + commandPort + ".");
};
