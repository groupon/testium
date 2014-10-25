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

assert = require 'assertive'
{isString, isRegExp} = require 'lodash'

isTextOrRegexp = (textOrRegExp) ->
  isString(textOrRegExp) || isRegExp(textOrRegExp)

ElementMixin =
  _getElementWithProperty: (selector, property) ->
    elements = @driver.getElements selector
    count = elements.length

    throw new Error "Element not found for selector: #{selector}" if count is 0
    throw new Error """assertion needs a unique selector!
      #{selector} has #{count} hits in the page""" unless count is 1

    element = elements[0]
    [ element, element.get(property) ]

  elementHasText: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementHasText(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementHasText: #{selector}"

    assert.truthy 'elementHasText(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementHasText(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualText] = @_getElementWithProperty(selector, 'text')

    if textOrRegExp == ''
      assert.equal textOrRegExp, actualText
    else
      assert.include doc, textOrRegExp, actualText

    element

  elementLacksText: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementLacksText(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementLacksText: #{selector}"

    assert.truthy 'elementLacksText(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementLacksText(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualText] = @_getElementWithProperty(selector, 'text')

    assert.notInclude doc, textOrRegExp, actualText
    element

  elementHasValue: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementHasValue(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementHasValue: #{selector}"

    assert.truthy 'elementHasValue(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementHasValue(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualValue] = @_getElementWithProperty(selector, 'value')

    if textOrRegExp == ''
      assert.equal textOrRegExp, actualValue
    else
      assert.include doc, textOrRegExp, actualValue

    element

  elementLacksValue: (selector, textOrRegExp) ->
    if arguments.length is 3
      [doc, selector, textOrRegExp] = arguments
      assert.truthy 'elementLacksValue(docstring, selector, textOrRegExp) - requires docstring', isString doc
    else
      doc = "elementLacksValue: #{selector}"

    assert.truthy 'elementLacksValue(selector, textOrRegExp) - requires selector', isString selector
    assert.truthy 'elementLacksValue(selector, textOrRegExp) - requires textOrRegExp', isTextOrRegexp textOrRegExp

    [element, actualValue] = @_getElementWithProperty(selector, 'value')

    assert.notInclude doc, textOrRegExp, actualValue
    element

  elementIsVisible: (selector) ->
    assert.hasType 'elementIsVisible(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.truthy "Element not found for selector: #{selector}", element
    assert.truthy "Element should be visible for selector: #{selector}", element.isVisible()
    element

  elementNotVisible: (selector) ->
    assert.hasType 'elementNotVisible(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.truthy "Element not found for selector: #{selector}", element
    assert.falsey "Element should not be visible for selector: #{selector}", element.isVisible()
    element

  elementExists: (selector) ->
    assert.hasType 'elementExists(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.truthy "Element not found for selector: #{selector}", element
    element

  elementDoesntExist: (selector) ->
    assert.hasType 'elementDoesntExist(selector) - requires (String) selector', String, selector
    element = @browser.getElementWithoutError selector
    assert.falsey "Element found for selector: #{selector}", element

module.exports = ElementMixin
