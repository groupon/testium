
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
var CHROME_MESSAGE, ElementMixin, FIREFOX_MESSAGE, PHANTOMJS_MESSAGE, STALE_MESSAGE, elementExistsFailure, elementExistsPredicate, hasType, isVisibleFailure, isVisiblePredicate, isntVisibleFailure, isntVisiblePredicate, partial, truthy, visibleFailure, visiblePredicate, _ref;

_ref = require('assertive'), truthy = _ref.truthy, hasType = _ref.hasType;

partial = require('lodash').partial;

STALE_MESSAGE = /stale element reference/;

FIREFOX_MESSAGE = /Unable to locate element/;

PHANTOMJS_MESSAGE = /Unable to find element/;

CHROME_MESSAGE = /no such element/;

visiblePredicate = function(shouldBeVisible, element) {
  return (element != null ? element.isVisible() : void 0) === shouldBeVisible;
};

visibleFailure = function(shouldBeVisible, selector, timeout) {
  var negate;
  negate = shouldBeVisible ? '' : 'not ';
  throw new Error("Timeout (" + timeout + "ms) waiting for element (" + selector + ") to " + negate + "be visible.");
};

elementExistsPredicate = function(element) {
  return element != null;
};

elementExistsFailure = function(selector, timeout) {
  throw new Error("Timeout (" + timeout + "ms) waiting for element (" + selector + ") to exist in page.");
};

isVisiblePredicate = partial(visiblePredicate, true);

isntVisiblePredicate = partial(visiblePredicate, false);

isVisibleFailure = partial(visibleFailure, true);

isntVisibleFailure = partial(visibleFailure, false);

ElementMixin = {
  getElementWithoutError: function(selector) {
    var exception, message;
    try {
      return this.driver.getElement(selector);
    } catch (_error) {
      exception = _error;
      message = exception.toString();
      if (FIREFOX_MESSAGE.test(message)) {
        return null;
      }
      if (PHANTOMJS_MESSAGE.test(message)) {
        return null;
      }
      if (CHROME_MESSAGE.test(message)) {
        return null;
      }
      throw exception;
    }
  },
  getElement: function(selector) {
    hasType('getElement(selector) - requires (String) selector', String, selector);
    return this.getElementWithoutError(selector);
  },
  getElements: function(selector) {
    hasType('getElements(selector) - requires (String) selector', String, selector);
    return this.driver.getElements(selector);
  },
  waitForElement: function(selector, timeout) {
    deprecate('waitForElement', 'waitForElementVisible');
    hasType('getElements(selector) - requires (String) selector', String, selector);
    return this._waitForElement(selector, isVisiblePredicate, isVisibleFailure, timeout);
  },
  waitForElementVisible: function(selector, timeout) {
    hasType('getElements(selector) - requires (String) selector', String, selector);
    return this._waitForElement(selector, isVisiblePredicate, isVisibleFailure, timeout);
  },
  waitForElementNotVisible: function(selector, timeout) {
    hasType('getElements(selector) - requires (String) selector', String, selector);
    return this._waitForElement(selector, isntVisiblePredicate, isntVisibleFailure, timeout);
  },
  waitForElementExist: function(selector, timeout) {
    hasType('getElements(selector) - requires (String) selector', String, selector);
    return this._waitForElement(selector, elementExistsPredicate, elementExistsFailure, timeout);
  },
  click: function(selector) {
    var element;
    hasType('click(selector) - requires (String) selector', String, selector);
    element = this.driver.getElement(selector);
    truthy("Element not found at selector: " + selector, element);
    return element.click();
  },
  _waitForElement: function(selector, predicate, failure, timeout) {
    var element, exception, foundElement, message, predicateResult, start;
    if (timeout == null) {
      timeout = 3000;
    }
    start = Date.now();
    this.driver.setElementTimeout(timeout);
    foundElement = null;
    while ((Date.now() - start) < timeout) {
      element = this.getElementWithoutError(selector);
      try {
        predicateResult = predicate(element);
      } catch (_error) {
        exception = _error;
        message = exception.toString();
        if (!STALE_MESSAGE.test(message)) {
          throw exception;
        }
      }
      if (predicateResult) {
        foundElement = element;
        break;
      }
    }
    this.driver.setElementTimeout(0);
    if (foundElement === null) {
      failure(selector, timeout);
    }
    return foundElement;
  }
};

module.exports = ElementMixin;
