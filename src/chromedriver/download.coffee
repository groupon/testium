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
{copy, move} = require 'fs.extra'
AdmZip = require 'adm-zip'
downloadFile = require '../download'
validate = require '../checksum'

unzip = (tempPath, filePath, callback) ->
  tempFilePath = "#{filePath}.tmp"
  move filePath, tempFilePath, (error) ->
    return callback error if error?

    zip = new AdmZip tempFilePath
    zip.extractAllTo tempPath
    fs.unlinkSync tempFilePath
    callback()

module.exports = (binPath, tempPath, version, url, callback) ->
  chromedriverPath = "#{binPath}/chromedriver"
  return callback() if fs.existsSync chromedriverPath

  tempFileName = "chromedriver_#{version}"
  tempFilePath = "#{tempPath}/#{tempFileName}"
  if fs.existsSync tempFilePath
    copy tempFilePath, chromedriverPath, (error) ->
      return callback error if error?
      fs.chmod chromedriverPath, '755', callback
  else

    unzippedFilePath = "#{tempPath}/chromedriver"
    async.waterfall [
      (done) -> downloadFile url, tempPath, tempFileName, done
      (hash, done) -> validate tempFilePath, hash, done
      (done) -> unzip tempPath, tempFilePath, done
      (done) -> move unzippedFilePath, tempFilePath, done
      (done) -> copy tempFilePath, chromedriverPath, done
      (done) -> fs.chmod chromedriverPath, '755', done
    ], callback

