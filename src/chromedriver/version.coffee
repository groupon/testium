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

FALLBACK_CHROMEDRIVER_VERSION = '2.9'

request = require 'request'
parseXml = require('xml2js').parseString

getArchitecture = ->
  platform = process.platform

  unless platform in ['linux', 'darwin', 'win32']
    throw new Error("Unsupported platform #{platform}. Only linux, darwin, and win32 are supported.")

  bitness = process.arch.substr(1)

  if platform == 'darwin'
    platform = 'mac'
    bitness = '32'

  if platform == 'win32'
    platform = 'win'
    bitness = '32'

  { platform, bitness }

parseChrome = (result) ->
  version = null
  error = null

  try
    prefixes = result.ListBucketResult.CommonPrefixes
    prefix = prefixes[prefixes.length-2] # last item is /Icons, get 2nd to last
    versionPath = prefix.Prefix[0] # something like "2.8/"
    version = versionPath.substring(0, versionPath.length-1)
  catch parseError
    error = parseError

  {error, version}

requestXml = (url, callback) ->
  request url, (error, response, body) ->
    return callback error if error?

    parseXml body, (error, result) ->
      return callback(error) if error?

      callback(null, result)

getLatestVersion = (callback) ->
  requestXml 'http://chromedriver.storage.googleapis.com/?delimiter=/&prefix=', (error, result) ->
    return callback(error) if error?

    {error, version} = parseChrome(result)
    callback error, version

module.exports = (callback) ->
  getLatestVersion (error, version) ->
    if error?
      version = FALLBACK_CHROMEDRIVER_VERSION
      console.log "[testium] Unable to determine latest version of selenium chromedriver; using #{version}"
      console.error (error.stack || error)

    {platform, bitness} = getArchitecture()
    downloadUrl = "https://chromedriver.storage.googleapis.com/#{version}/chromedriver_#{platform}#{bitness}.zip"

    callback null, { downloadUrl, version }

