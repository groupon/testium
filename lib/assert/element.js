
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
var ElementMixin, assert, isRegExp, isString, isTextOrRegexp, _ref;

assert = require('assertive');

_ref = require('lodash'), isString = _ref.isString, isRegExp = _ref.isRegExp;

isTextOrRegexp = function(textOrRegExp) {
  return isString(textOrRegExp) || isRegExp(textOrRegExp);
};

ElementMixin = {
  _getElementWithProperty: function(selector, property) {
    var count, element, elements;
    elements = this.driver.getElements(selector);
    count = elements.length;
    if (count === 0) {
      throw new Error("Element not found for selector: " + selector);
    }
    if (count !== 1) {
      throw new Error("assertion needs a unique selector!\n" + selector + " has " + count + " hits in the page");
    }
    element = elements[0];
    return [element, element.get(property)];
  },
  elementHasText: function(selector, textOrRegExp) {
    var actualText, doc, element, _ref1;
    if (arguments.length === 3) {
      doc = arguments[0], selector = arguments[1], textOrRegExp = arguments[2];
      assert.truthy('elementHasText(docstring, selector, textOrRegExp) - requires docstring', isString(doc));
    } else {
      doc = "elementHasText: " + selector;
    }
    assert.truthy('elementHasText(selector, textOrRegExp) - requires selector', isString(selector));
    assert.truthy('elementHasText(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp(textOrRegExp));
    _ref1 = this._getElementWithProperty(selector, 'text'), element = _ref1[0], actualText = _ref1[1];
    if (textOrRegExp === '') {
      assert.equal(textOrRegExp, actualText);
    } else {
      assert.include(doc, textOrRegExp, actualText);
    }
    return element;
  },
  elementLacksText: function(selector, textOrRegExp) {
    var actualText, doc, element, _ref1;
    if (arguments.length === 3) {
      doc = arguments[0], selector = arguments[1], textOrRegExp = arguments[2];
      assert.truthy('elementLacksText(docstring, selector, textOrRegExp) - requires docstring', isString(doc));
    } else {
      doc = "elementLacksText: " + selector;
    }
    assert.truthy('elementLacksText(selector, textOrRegExp) - requires selector', isString(selector));
    assert.truthy('elementLacksText(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp(textOrRegExp));
    _ref1 = this._getElementWithProperty(selector, 'text'), element = _ref1[0], actualText = _ref1[1];
    assert.notInclude(doc, textOrRegExp, actualText);
    return element;
  },
  elementHasValue: function(selector, textOrRegExp) {
    var actualValue, doc, element, _ref1;
    if (arguments.length === 3) {
      doc = arguments[0], selector = arguments[1], textOrRegExp = arguments[2];
      assert.truthy('elementHasValue(docstring, selector, textOrRegExp) - requires docstring', isString(doc));
    } else {
      doc = "elementHasValue: " + selector;
    }
    assert.truthy('elementHasValue(selector, textOrRegExp) - requires selector', isString(selector));
    assert.truthy('elementHasValue(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp(textOrRegExp));
    _ref1 = this._getElementWithProperty(selector, 'value'), element = _ref1[0], actualValue = _ref1[1];
    if (textOrRegExp === '') {
      assert.equal(textOrRegExp, actualValue);
    } else {
      assert.include(doc, textOrRegExp, actualValue);
    }
    return element;
  },
  elementLacksValue: function(selector, textOrRegExp) {
    var actualValue, doc, element, _ref1;
    if (arguments.length === 3) {
      doc = arguments[0], selector = arguments[1], textOrRegExp = arguments[2];
      assert.truthy('elementLacksValue(docstring, selector, textOrRegExp) - requires docstring', isString(doc));
    } else {
      doc = "elementLacksValue: " + selector;
    }
    assert.truthy('elementLacksValue(selector, textOrRegExp) - requires selector', isString(selector));
    assert.truthy('elementLacksValue(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp(textOrRegExp));
    _ref1 = this._getElementWithProperty(selector, 'value'), element = _ref1[0], actualValue = _ref1[1];
    assert.notInclude(doc, textOrRegExp, actualValue);
    return element;
  },
  elementIsVisible: function(selector) {
    var element;
    assert.hasType('elementIsVisible(selector) - requires (String) selector', String, selector);
    element = this.browser.getElementWithoutError(selector);
    assert.truthy("Element not found for selector: " + selector, element);
    assert.truthy("Element should be visible for selector: " + selector, element.isVisible());
    return element;
  },
  elementNotVisible: function(selector) {
    var element;
    assert.hasType('elementNotVisible(selector) - requires (String) selector', String, selector);
    element = this.browser.getElementWithoutError(selector);
    assert.truthy("Element not found for selector: " + selector, element);
    assert.falsey("Element should not be visible for selector: " + selector, element.isVisible());
    return element;
  },
  elementExists: function(selector) {
    var element;
    assert.hasType('elementExists(selector) - requires (String) selector', String, selector);
    element = this.browser.getElementWithoutError(selector);
    assert.truthy("Element not found for selector: " + selector, element);
    return element;
  },
  elementDoesntExist: function(selector) {
    var element;
    assert.hasType('elementDoesntExist(selector) - requires (String) selector', String, selector);
    element = this.browser.getElementWithoutError(selector);
    return assert.falsey("Element found for selector: " + selector, element);
  }
};

module.exports = ElementMixin;
