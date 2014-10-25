
/*
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
 */
var debug, getScreenshotData, mkdirp, takeScreenshot, takeScreenshotOnFailure, writeFile, writeImageDiff, writeScreenshot;

debug = require('debug')('testium:mocha:screenshot');

mkdirp = require('mkdirp');

writeFile = require('./write_file');

writeScreenshot = function(browser, rawData, directory, title) {
  var screenshotData, screenshotFile;
  screenshotData = getScreenshotData(browser, rawData);
  if (screenshotData == null) {
    return;
  }
  screenshotFile = writeFile(directory, title, screenshotData, 'base64');
  return '\n' + ("[TESTIUM] Saved screenshot " + screenshotFile);
};

writeImageDiff = function(images, title, directory) {
  var diff, image1, image2, path1, path2, pathDiff;
  image1 = images.image1, image2 = images.image2, diff = images.diff;
  path1 = writeFile(directory, "" + title + "-compared1", image1);
  path2 = writeFile(directory, "" + title + "-compared2", image2);
  pathDiff = writeFile(directory, "" + title + "-diff", diff);
  return '\n' + ("Image 1 saved at: " + path1 + "\nImage 2 saved at: " + path2 + "\nDiff saved at: " + pathDiff);
};

getScreenshotData = function(browser, rawData) {
  var error;
  if ('string' === typeof rawData) {
    return new Buffer(rawData, 'base64');
  }
  try {
    return browser.getScreenshot();
  } catch (_error) {
    error = _error;
    console.error("Error grabbing screenshot: " + error.message);
  }
};

takeScreenshot = function(directory, test, browser, done) {
  return mkdirp(directory, function(err) {
    var message, title;
    if (err != null) {
      return done(err);
    }
    title = test.fullTitle();
    message = test.err.compareImages != null ? writeImageDiff(test.err.compareImages, title, directory) : writeScreenshot(browser, test.err.screen, directory, title);
    test.err.message = "" + test.err.message + message;
    return done();
  });
};

takeScreenshotOnFailure = function(directory) {
  return function(done) {
    var _ref;
    if (this.browser == null) {
      return done();
    }
    if (((_ref = this.currentTest) != null ? _ref.state : void 0) !== 'failed') {
      return done();
    }
    return takeScreenshot(directory, this.currentTest, this.browser, done);
  };
};

module.exports = takeScreenshotOnFailure;
