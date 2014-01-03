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

fs = require 'fs'
http = require 'http'
mkdirp = require 'mkdirp'
async = require 'async'
AdmZip = require('adm-zip')
{copy, move} = require 'fs.extra'
getLatestVersions = require './versions'

BIN_PATH = "#{__dirname}/../../bin"
TEMP_PATH = '/tmp/testium'
CHROMEDRIVER_PATH = "#{BIN_PATH}/chromedriver"
CHROMEDRIVER_TEMP_PATH = "#{TEMP_PATH}/chromedriver"
CHROMEDRIVER_ZIP_TEMP_PATH = "#{CHROMEDRIVER_TEMP_PATH}.zip"
SELENIUM_JAR_PATH = "#{BIN_PATH}/selenium.jar"
SELENIUM_TEMP_PATH = "#{TEMP_PATH}/selenium.jar"

# fallbacks if the version detection fails
CHROMEDRIVER_VERSION = '2.8'
SELENIUM_VERSION = '2.38.0'

doneEvent = do ->
  nodeVersion = Number(process.version.match(/^v(\d+\.\d+)/)[1])
  if nodeVersion < 0.99
    'end'
  else
    'finish'

exists = (filePath) ->
  fs.existsSync filePath

downloadFile = (url, filePath, callback) ->
  file = fs.createWriteStream(filePath)
  http.get url, (response) ->
    response.pipe(file)
    response.on doneEvent, ->
      callback()

ensureSelenium = (version) ->
  (callback) ->
    url = "http://selenium.googlecode.com/files/selenium-server-standalone-#{version}.jar"
    file = 'selenium.jar'
    binFilePath = "#{BIN_PATH}/#{file}"
    return callback() if exists binFilePath

    console.log "[testium] grabbing selenium standalone server #{version}"

    tempFilePath = "#{TEMP_PATH}/selenium_#{version}.jar"
    if exists tempFilePath
      copy tempFilePath, binFilePath, callback
    else
      downloadFile url, tempFilePath, ->
        copy tempFilePath, binFilePath, callback

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

unzip = (filePath, callback) ->
  # This is file-based instead of stream-based
  # because none of the stream options worked for me
  tempFilePath = "#{filePath}.tmp"
  move filePath, tempFilePath, ->
    zip = new AdmZip tempFilePath
    zip.extractAllTo TEMP_PATH
    fs.unlinkSync tempFilePath
    callback()

ensureChromeDriver = (version) ->
  (callback) ->
    {platform, bitness} = getArchitecture()
    url = "http://chromedriver.storage.googleapis.com/#{version}/chromedriver_#{platform}#{bitness}.zip"
    return callback() if exists CHROMEDRIVER_PATH

    console.log "[testium] grabbing selenium chromedriver #{version}"

    tempFilePath = "#{TEMP_PATH}/chromedriver_#{version}"
    if exists tempFilePath
      copy tempFilePath, CHROMEDRIVER_PATH, callback
    else
      downloadFile url, tempFilePath, ->
        unzip tempFilePath, ->
          move "#{TEMP_PATH}/chromedriver", tempFilePath, ->
            copy tempFilePath, CHROMEDRIVER_PATH, ->
              fs.chmod CHROMEDRIVER_PATH, '755', callback

makePaths = ->
  mkdirp.sync BIN_PATH
  mkdirp.sync TEMP_PATH

exit = (error) ->
  console.error error if error?
  process.exit(if error? then 1 else 0)


makePaths()
getLatestVersions SELENIUM_VERSION, CHROMEDRIVER_PATH, (error, versions) ->
  return exit(error) if error?

  async.parallel [
    ensureSelenium(versions.selenium)
    ensureChromeDriver(versions.chromedriver)
  ], exit

