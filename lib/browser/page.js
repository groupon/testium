
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
var cropScreenshot, hasType;

cropScreenshot = require('../img_diff').crop;

hasType = require('assertive').hasType;

module.exports = {
  getPageTitle: function() {
    return this.driver.getPageTitle();
  },
  getPageSource: function() {
    return this.driver.getPageSource();
  },
  _cropScreenshotBySelector: function(screenshot, selector) {
    var element, elementData, position, size;
    element = this.driver.getElement(selector);
    position = element.getLocationInView();
    size = element.getSize();
    elementData = {
      x: position.x,
      y: position.y,
      width: size.width,
      height: size.height
    };
    return cropScreenshot(screenshot, elementData);
  },
  getScreenshot: function(selector) {
    var screenshot;
    if (selector != null) {
      hasType('getScreenshot(selector) - requires (String) selector or nothing', String, selector);
      screenshot = this.driver.getScreenshot();
      return this._cropScreenshotBySelector(screenshot, selector);
    } else {
      return this.driver.getScreenshot();
    }
  },
  setPageSize: function(size) {
    var height, invocation, width;
    invocation = 'setPageSize(size={height, width})';
    hasType("" + invocation + " - requires (Object) size", Object, size);
    height = size.height, width = size.width;
    hasType("" + invocation + " - requires (Number) size.height", Number, height);
    hasType("" + invocation + " - requires (Number) size.width", Number, width);
    return this.driver.setPageSize({
      height: height,
      width: width
    });
  },
  getPageSize: function() {
    return this.driver.getPageSize();
  }
};
