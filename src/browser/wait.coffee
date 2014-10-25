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

{isString, isRegExp} = require 'lodash'

module.exports = (stringOrRegex, waitingFor, getValue, timeout) ->
  test = null

  if isString stringOrRegex
    test = (testUrl) ->
      stringOrRegex == testUrl
  else if isRegExp stringOrRegex
    test = (testUrl) ->
      stringOrRegex.test(testUrl)
  else
    throw new Error "waitFor#{waitingFor}(urlStringOrRegex) - requires a string or regex param for the #{waitingFor}"

  success = false
  currentValue = null

  start = Date.now()
  while (Date.now() - start) < timeout
    currentValue = getValue()
    if test(currentValue)
      success = true
      break

  if !success
    lowerWaitingFor = waitingFor.toLowerCase()
    throw new Error "Timed out (#{timeout}ms) waiting for #{lowerWaitingFor} (#{stringOrRegex}). Last #{lowerWaitingFor} was: #{currentValue}"
