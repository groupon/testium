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

writeFile = require './write_file'

getComparisonMessage = (images, title, screenshotDirectory) ->
  {image1, image2, diff} = images
  path1 = writeFile screenshotDirectory, "#{title}-compared1", image1
  path2 = writeFile screenshotDirectory, "#{title}-compared2", image2
  pathDiff = writeFile screenshotDirectory, "#{title}-diff", diff

  message =  "\n    Image 1 saved at: #{path1}"
  message += "\n    Image 2 saved at: #{path2}"
  message += "\n    Diff saved at: #{pathDiff}"

  message

getScreenshotMessage = (driver, screen, screenshotDirectory, title) ->
  screenshotData = getScreenshotData(driver, screen)
  return unless screenshotData?

  screenshotFile = writeFile screenshotDirectory, title, screenshotData, 'base64'
  screenshotMessage = "[TESTIUM] Saved screenshot #{screenshotFile}"
  "\n    #{screenshotMessage}"

module.exports.takeScreenshotOnFailure = (screenshotDirectory, test, driver) ->
  return unless screenshotDirectory
  return unless test?.state == 'failed'
  return unless driver?

  title = test.title

  message = if test.err.compareImages?
    getComparisonMessage(test.err.compareImages, title, screenshotDirectory)
  else
    getScreenshotMessage(driver, test.err.screen, screenshotDirectory, title)

  test.err.message = "#{test.err.message}#{message}"

getScreenshotData = (driver, screen) ->
  if 'string' == typeof screen
    return new Buffer(screen, 'base64')

  try
    driver.getScreenshot()
  catch error
    console.error "Error grabbing screenshot: #{error.message}"
    return

