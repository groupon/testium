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

fs = require 'fs'
async = require 'async'
AdmZip = require 'adm-zip'
{copy, move} = require 'fs.extra'
downloadFile = require './download'

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

unzip = (tempPath, filePath, callback) ->
  # This is file-based instead of stream-based
  # because none of the stream options worked for me
  tempFilePath = "#{filePath}.tmp"
  move filePath, tempFilePath, (error) ->
    return callback error if error?

    zip = new AdmZip tempFilePath
    zip.extractAllTo tempPath
    fs.unlinkSync tempFilePath
    callback()

module.exports = (binPath, tempPath, version) ->
  (callback) ->
    {platform, bitness} = getArchitecture()
    url = "https://chromedriver.storage.googleapis.com/#{version}/chromedriver_#{platform}#{bitness}.zip"
    chromedriverPath = "#{binPath}/chromedriver"
    return callback() if fs.existsSync chromedriverPath

    console.log "[testium] grabbing selenium chromedriver #{version}"

    tempFilePath = "#{tempPath}/chromedriver_#{version}"
    if fs.existsSync tempFilePath
      copy tempFilePath, chromedriverPath, (error) ->
        return callback error if error?
        fs.chmod chromedriverPath, '755', callback
    else

      async.series [
        (done) -> downloadFile url, tempFilePath, done
        (done) -> unzip tempPath, tempFilePath, done
        (done) -> move "#{tempPath}/chromedriver", tempFilePath, done
        (done) -> copy tempFilePath, chromedriverPath, done
        (done) -> fs.chmod chromedriverPath, '755', done
      ], callback

