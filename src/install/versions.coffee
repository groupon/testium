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

FALLBACK_CHROMEDRIVER_VERSION = '2.8'
FALLBACK_SELENIUM_VERSION = '2.39.0'

async = require 'async'
request = require 'request'
parseXml = require('xml2js').parseString

getLatestSeleniumVersion = (callback) ->
  request 'https://code.google.com/p/selenium/downloads/list', (error, response, body) ->
    return callback error if error?

    versionRegex = /selenium-server-standalone-(\d+.\d+.\d+)\.jar/
    version = versionRegex.exec(body)[1]
    callback(null, version)

getLatestChromedriverVersion = (callback) ->
  request 'http://chromedriver.storage.googleapis.com/?delimiter=/&prefix=', (error, response, body) ->
    return callback(error) if error?

    parseXml body, (error, result) ->
      return callback(error) if error?

      prefixes = result.ListBucketResult.CommonPrefixes
      prefix = prefixes[prefixes.length-2] # last item is /Icons, get 2nd to last
      versionPath = prefix.Prefix[0] # something like "2.8/"
      version = versionPath.substring(0, versionPath.length-1)
      callback null, version

module.exports = (callback) ->
  async.parallel [
    getLatestSeleniumVersion
    getLatestChromedriverVersion
  ], (error, results) ->
    return callback error if error?

    selenium = FALLBACK_SELENIUM_VERSION
    chromedriver = FALLBACK_CHROMEDRIVER_VERSION

    if !results?[0]
      console.log "[testium] Unable to determine latest version of selenium standalone server; using #{selenium}"
    else
      selenium = results[0]

    if !results?.length > 1 || !results?[1]
      console.log "[testium] Unable to determine latest version of selenium chromedriver; using #{chromedriver}"
    else
      chromedriver = results[1]

    callback null, { selenium, chromedriver }

