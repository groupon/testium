
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
module.exports = function(selector) {
  var describe, img, imgs, oops, _ref;
  describe = function(elem) {
    var classes, tag, _ref;
    tag = (_ref = elem.tagName) != null ? _ref.toLowerCase() : void 0;
    if (tag == null) {
      tag = '';
    }
    if (elem.id) {
      tag += '#' + elem.id;
    }
    if (classes = elem.className.replace(/^\s+|\s+$/g, '')) {
      tag += "." + (classes.replace(/\s+/g, '.'));
    }
    return tag;
  };
  img = (imgs = document.querySelectorAll(selector))[0];
  if (imgs.length !== 1) {
    return imgs.length;
  }
  if (!img.src) {
    oops = describe(img);
    if ((_ref = img.tagName) != null ? _ref.match(/^img$/i) : void 0) {
      oops = "src-less " + oops;
    } else {
      oops = "non-image " + oops;
    }
    return oops;
  }
  if (img.complete && img.naturalWidth) {
    return true;
  } else {
    return img.src;
  }
};
