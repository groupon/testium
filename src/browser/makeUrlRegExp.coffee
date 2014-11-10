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

{isRegExp} = require 'lodash'

quoteRegExp = (string) ->
  string.replace /[-\\\/\[\]{}()*+?.^$|]/g, '\\$&'

bothCases = (alpha) ->
  up = alpha.toUpperCase()
  dn = alpha.toLowerCase()
  "[#{ up }#{ dn }]"

isHexaAlphaRE = /[a-f]/gi

matchCharacter = (uriEncoded, hex) ->
  uriEncoded = uriEncoded.replace isHexaAlphaRE, bothCases
  codepoint = parseInt hex, 16
  character = String.fromCharCode codepoint
  character = quoteRegExp character
  character += '|\\+'  if character is ' ' # grok form-url-encoded spaces too
  "(?:#{ uriEncoded }|#{ character })"

encodedCharRE = /%([0-9a-f]{2})/gi

# produce a regexp string that matches a URI-encoded or non-URI-encoded string
matchURI = (stringOrRegExp) ->
  if isRegExp stringOrRegExp # just strip literal /s (and trailing flags) flags
    return stringOrRegExp.toString().replace /^\/|\/\w*$/g, ''

  fullyEncoded = encodeURIComponent stringOrRegExp
  quoteRegExp(fullyEncoded).replace encodedCharRE, matchCharacter

module.exports = (url, query = {}) ->
  url = matchURI url

  for own key, val of query
    key = matchURI key
    val = matchURI val
    # match every query param via a clever positive look-ahead hack
    url += "(?=(?:\\?|.*&)#{ key }=#{ val })"

  new RegExp url
