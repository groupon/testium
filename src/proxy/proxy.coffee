###
Copyright (c) 2013, Groupon, Inc.
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

http = require('http')
url = require('url')
concat = require('concat-stream')

buildRemoteRequestOptions = (request, toPort) ->
  uri = url.parse(request.url)
  opt =
    port: toPort
    path: uri.path
    method: request.method
    headers: request.headers

  opt.headers['connection'] = 'keep-alive'
  opt.headers['cache-control'] = 'no-store'
  delete opt.headers['if-none-match']
  delete opt.headers['if-modified-since']
  opt

openRequests = []
firstPage = true
newPage = true
newPageOptions = {}
markNewPage = (body, response) ->
  newPageOptions = body || {}
  console.log "\n[System] Marking new page request with options: #{JSON.stringify newPageOptions}"

  for request in openRequests
    console.log '[System] Aborting request for: ' + request.path
    request.aborted = true
    request.abort()
  openRequests = []

  newPage = true
  response.end()

markRequestClosed = (targetRequest) ->
  openRequests = openRequests.filter (request) ->
    request != targetRequest

commandError = (url, response) ->
  console.log "[System] Unknown command: #{url}"
  response.statusCode = 500
  response.writeHead response.statusCode, response.headers
  response.end()

success = (response) ->
  response.statusCode = 200
  response.writeHead response.statusCode, response.headers
  response.end()

proxyCommand = (url, body, response) ->
  switch url
    when '/new-page' then markNewPage(body, response)
    else commandError(url, response)

modifyRequest = (request, options) ->
  return unless options.headers?

  for header, value of options.headers
    request.headers[header] = value

proxyRequest = (request, response, modifyResponse, toPort) ->
  console.log "--> #{request.method} #{request.url}"

  remoteRequestOptions = buildRemoteRequestOptions(request, toPort)
  console.log "    #{JSON.stringify remoteRequestOptions}"

  if request.url.indexOf('/favicon.ico') != 0
    if firstPage
      firstPage = false
      return success(response)
    else if newPage
      modifyRequest(remoteRequestOptions, newPageOptions)

  remoteRequest = http.request remoteRequestOptions, (remoteResponse) ->
    markRequestClosed(remoteRequest)

    if newPage && request.url.indexOf('/favicon.ico') != 0
      newPage = false
      modifyResponse(remoteResponse)

    response.writeHead remoteResponse.statusCode, remoteResponse.headers
    remoteResponse.on 'end', ->
      console.log "<-- #{response.statusCode} #{request.url}"

    remoteResponse.pipe response

  remoteRequest.on 'error', (error) ->
    response.statusCode = 500
    console.log JSON.stringify error, ['message', 'stack'], 2
    console.log '<-- ' + response.statusCode + ' ' + request.url

    markRequestClosed(remoteRequest)

    if newPage && request.url.indexOf('/favicon.ico') != 0 && !remoteRequest.aborted
      modifyResponse(response)

    newPage = false
    response.writeHead response.statusCode, response.headers
    response.end()

  openRequests.push remoteRequest

  request.pipe remoteRequest
  request.on 'end', ->
    remoteRequest.end()

server = null
commandServer = null
module.exports = (fromPort, toPort, commandPort, modifyResponse) ->
  server = http.createServer (request, response) ->
    proxyRequest(request, response, modifyResponse, toPort)
  server.listen fromPort
  console.log "Listening on port #{fromPort} and proxying to #{toPort}."

  commandServer = http.createServer (request, response) ->
    request.pipe concat (body) ->
      if body?
        options = JSON.parse(body.toString())
      proxyCommand(request.url, options, response)
  commandServer.listen commandPort
  console.log "Listening for commands on port #{commandPort}."

