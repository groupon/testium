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

debug = require('debug')('testium:mocha:screenshot')
mkdirp = require 'mkdirp'

writeFile = require './write_file'

writeScreenshot = (browser, rawData, directory, title) ->
  screenshotData = getScreenshotData(browser, rawData)
  return unless screenshotData?

  screenshotFile = writeFile directory, title, screenshotData, 'base64'
  '\n' + """
      [TESTIUM] Saved screenshot #{screenshotFile}
  """

writeImageDiff = (images, title, directory) ->
  {image1, image2, diff} = images
  path1 = writeFile directory, "#{title}-compared1", image1
  path2 = writeFile directory, "#{title}-compared2", image2
  pathDiff = writeFile directory, "#{title}-diff", diff

  '\n' + """
      Image 1 saved at: #{path1}
      Image 2 saved at: #{path2}
      Diff saved at: #{pathDiff}
  """

getScreenshotData = (browser, rawData) ->
  if 'string' == typeof rawData
    return new Buffer(rawData, 'base64')

  try
    browser.getScreenshot()
  catch error
    console.error "Error grabbing screenshot: #{error.message}"
    return

takeScreenshot = (directory, test, browser, done) ->
  mkdirp directory, (err) ->
    return done(err) if err?

    title = test.fullTitle()

    message =
      if test.err.compareImages?
        writeImageDiff(test.err.compareImages, title, directory)
      else
        writeScreenshot(browser, test.err.screen, directory, title)

    test.err.message = "#{test.err.message}#{message}"
    done()

takeScreenshotOnFailure = (directory) ->
  (done) ->
    return done() unless @browser?
    return done() unless @currentTest?.state == 'failed'

    takeScreenshot directory, @currentTest, @browser, done

module.exports = takeScreenshotOnFailure
