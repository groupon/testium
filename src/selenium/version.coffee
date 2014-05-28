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

buildDownloadUrl = (version, minorVersion) ->
  "http://selenium-release.storage.googleapis.com/#{minorVersion}/selenium-server-standalone-#{version}.jar"

FALLBACK_SELENIUM_VERSION = '2.41.0'
FORCE_SELENIUM_VERSION =
  downloadUrl: buildDownloadUrl('2.41.0', '2.41')
  version: '2.41.0'

request = require 'request'
parseXml = require('xml2js').parseString
{find} = require 'underscore'

parseSeleniumMinor = (result) ->
  minorVersion = null
  error = null

  try
    prefixes = result.ListBucketResult.CommonPrefixes
    prefix = prefixes[prefixes.length-2] # last item is /Icons, get 2nd to last
    versionPath = prefix.Prefix[0] # something like "2.41.0/"
    minorVersion = versionPath.substring(0, versionPath.length-1)
  catch parseError
    error = parseError

  {error, minorVersion}

parseSelenium = (result) ->
  version = null
  error = null

  try
    contents = result.ListBucketResult.Contents
    content = find contents, (content) ->
      content.Key[0].match /selenium-server-standalone-/
    version = content.Key[0].match(/(\d+\.\d+\.\d+)/)[0]
  catch parseError
    error = parseError

  {error, version}

requestXml = (url, callback) ->
  request url, (error, response, body) ->
    return callback error if error?

    parseXml body, (error, result) ->
      return callback(error) if error?

      callback(null, result)

getMinor = (version) ->
  # "1.2.3" -> "1.2"
  version.split('.').slice(0, 2).join('.')

getLatestVersion = (callback) ->
  url = 'http://selenium-release.storage.googleapis.com/?delimiter=/&prefix='
  requestXml url, (error, result) ->
    return callback error if error?

    {error, minorVersion} = parseSeleniumMinor(result)
    return callback(error) if error?

    requestXml "http://selenium-release.storage.googleapis.com/?delimiter=/&prefix=#{minorVersion}/", (error, result) ->
      return callback(error) if error?

      {error, version} = parseSelenium(result)
      callback error, version


module.exports = (callback) ->
  if FORCE_SELENIUM_VERSION?
    return callback null, FORCE_SELENIUM_VERSION

  getLatestVersion (error, version) ->
    if error?
      version = FALLBACK_SELENIUM_VERSION
      console.log "[testium] Unable to determine latest version of selenium standalone server; using #{version}"
      console.error (error.stack || error)

    minorVersion = getMinor(version)
    downloadUrl = buildDownloadUrl(version, minorVersion)

    callback null, { downloadUrl, version }

