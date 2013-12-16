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

BIN_PATH = "#{__dirname}/../bin"
CHROMEDRIVER_PATH = "#{BIN_PATH}/chromedriver"
CHROMEDRIVER_ZIP_PATH = "#{CHROMEDRIVER_PATH}.zip"
CHROMEDRIVER_VERSION = '2.8'
SELENIUM_JAR_PATH = "#{BIN_PATH}/selenium.jar"
SELENIUM_VERSION = '2.39.0'

ensureSelenium = (callback) ->
  console.log '[Selenium] checking if standalone server jar exists: ' + SELENIUM_JAR_PATH
  return console.log '[Selenium] found' if fs.existsSync(SELENIUM_JAR_PATH)

  console.log '[Selenium] standalone server jar'
  url = "http://selenium.googlecode.com/files/selenium-server-standalone-#{SELENIUM_VERSION}.jar"
  file = fs.createWriteStream(SELENIUM_JAR_PATH)
  http.get url, (response) ->
    response.pipe(file)
    response.on 'end', ->
      console.log '[Selenium] download complete'
      callback()

getArchitecture = ->
  platform = process.platform

  unless platform in ['linux', 'darwin', 'win32']
    throw new Error('Unsupported platform #{platform}. Only linux, darwin, and win32 are supported.')

  bitness = process.arch.substr(1)

  if platform == 'darwin'
    platform = 'mac'
    bitness = '32'

  if platform == 'win32'
    platform = 'win'
    bitness = '32'

  { platform, bitness }

unzipChromedriver = ->
  # This is file-based instead of stream-based
  # because none of the stream options work
  # for various reasons
  # If you can fix this, feel free to try!
  zip = new AdmZip CHROMEDRIVER_ZIP_PATH
  zip.extractAllTo BIN_PATH
  fs.unlinkSync CHROMEDRIVER_ZIP_PATH

downloadChromeDriver = (callback) ->
  console.log '[ChromeDriver] downloading driver'

  { platform, bitness } = getArchitecture()

  url = "http://chromedriver.storage.googleapis.com/#{CHROMEDRIVER_VERSION}/chromedriver_#{platform}#{bitness}.zip"
  file = fs.createWriteStream(CHROMEDRIVER_ZIP_PATH)
  http.get url, (response) ->
    response.on 'end', ->
      unzipChromedriver()
      console.log '[ChromeDriver] download complete'
      callback()

    response.pipe(file)

ensureChromeDriver = (callback) ->
  console.log '[ChromeDriver] checking if driver exists: ' + CHROMEDRIVER_PATH
  return console.log '[ChromeDriver] found' if fs.existsSync(CHROMEDRIVER_PATH)

  downloadChromeDriver ->
    fs.chmodSync(CHROMEDRIVER_PATH, '755')
    callback()

makePath = (callback) ->
  mkdirp BIN_PATH, callback

async.parallel [
  makePath
  ensureSelenium
  ensureChromeDriver
], (error) ->
  console.error error if error?
  process.exit(if error? then 1 else 0)

