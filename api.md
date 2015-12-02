---
title: API
layout: sidebar
---

## Testium API

Below is the complete description of the Testium API.

### Browser

Getting the browser:

```coffee
{getBrowser} = require 'testium'
getBrowser options, (error, browser) ->
```

Inject browser into a mocha test context:

```coffee
injectBrowser = require 'testium/mocha'
describe 'injecting a browser', ->
  before injectBrowser(options)

  it 'has a browser', -> @browser
```

In both cases `options` are optional. Available options:

* `reuseSession`: Use the same session across tests, default: `true`
* `keepCookies`: Don't clear cookies, default: `false`

The details of `getBrowser` depend on the testium config.
You can read more about available options in the README.

#### browser.appUrl

Exposes the url of the application.
Useful if you want to make requests bypassing the browser.

#### browser.navigateTo(url, options)

Navigates the browser to the specificed relative or absolute url.

If `url` is the same as the current url,
a page refresh is forced.
This deviates from the WebDriver spec.

**relative urls**

If relative, the root is assumed to be `http://127.0.0.1:#{applicationPort}`,
where `applicationPort` can be configured via `app.port`.

```coffee
# navigates to "http://127.0.0.1:#{applicationPort}/products"
browser.navigateTo('/products')
```

**absolute urls**

If the url is absolute,
any methods that depend on the proxy
(`getStatusCode` and `getHeaders`)
will not work.
This is a bug and will be fixed.

```coffee
browser.navigateTo('http://www.google.com')

# fails
browser.getStatusCode()
```

**options**

The following types of options
can be provided.

```coffee
options:
  query:
    someQueryParam: 'someQueryValue'
  headers:
    locale: 'en_US'
```

The `headers` key provides
headers to pass along with the request.

```coffee
browser.navigateTo '/products', headers: {
  locale: 'en_US'
}
```

The `query` key provides an object
that will be converted to a querystring.

```coffee
# navigates to "/products?start=50&count=25"
browser.navigateTo '/products', query: {
  start: 50
  count: 25
}
```

#### browser.refresh()

Refresh the current page.

```coffee
browser.refresh()
```

#### browser.capabilities

Is an object describing the
[Capabilities](#capabilities)
that the current browser supports.

```coffee
# only define a test if the current browser
# can work with alerts
if browser.capabilities.handlesAlerts
  it 'shows an alert', ->
    browser.click '.show-alert'
    browser.acceptAlert()
else
  browserName = browser.capabilities.browserName
  xit 'pending: "shows an alert" because #{browserName} does not support alerts'
```

#### browser.getElement(cssSelector)

Finds an element on the page
using the `cssSelector`
and returns an [Element](#element).

```coffee
button = browser.getElement('.button')
button.click()
```

#### browser.getElementOrNull(cssSelector)

Finds an element on the page
using the `cssSelector`
and returns an [Element](#element).
Returns `null` if the element wasn't found.

```coffee
button = browser.getElementOrNull('.button')
button?.click()
```

#### browser.getElements(cssSelector)

Finds all elements on the page
using the `cssSelector`
and returns an array of
[Element](#element) objects.

```coffee
fields = browser.getElements('input')
```

#### browser.waitForElementExist(cssSelector, timeout=3000)

Waits for the element at `cssSelector`
to exist,
then returns the [Element](#element).
Times out after `timeout` milliseconds.
Visibility is not considered.

```coffee
browser.click '.menu-button'
# wait up to 1 second
# for the menu to be in the DOM
browser.waitForElementExist('.menu', 1000)
```

#### browser.waitForElementVisible(cssSelector, timeout=3000)

Waits for the element at `cssSelector`
to exist and be visible,
then returns the [Element](#element).
Times out after `timeout` milliseconds.

```coffee
browser.click '.menu-button'
# wait up to 1 second
# for the menu to show up
browser.waitForElementVisible('.menu', 1000)
```

#### browser.waitForElementNotVisible(cssSelector, timeout=3000)

Waits for the element at `cssSelector`
to exist and not be visible,
then returns the [Element](#element).
Times out after `timeout` milliseconds.

```coffee
browser.click '.menu-button'
# wait up to 1 second
# for the menu to be hidden
browser.waitForElementNotVisible('.menu', 1000)
```

#### browser.getUrl()

Returns the current url
('http://127.0.0.1:1234/some/route')
of the page.

```coffee
assert = require 'assertive'
url = browser.getUrl()
assert.equal 'is SSL', 0, url.indexOf('https')
```

#### browser.waitForUrl(url, timeout=5000)

Waits `timeout` milliseconds
for the browser to be at the specified `url`.
`url` can be a String, or a Regular Expression.

```coffee
# wait up to 1 second for the url
# to be exactly "http://127.0.0.1:3000/confirmation"
browser.waitForUrl('http://127.0.0.1:3000/confirmation', 1000)
```

#### browser.waitForUrl(url, query, timeout=5000)

Waits `timeout` milliseconds
for the browser
to be at the specified `url`
with query parameters
in the `query` object.

This allows the query params
to be specified as an object
instead of a specificly ordered
query string.

`url` can be a String, or a Regular Expression.

```coffee
browser.navigateTo '/products?start=30&count=15'
# returns immediately
browser.waitForUrl '/products', {
  start: 30
  count: 15
}

# order doesn't matter

browser.navigateTo '/products?count=15&start=30'
# returns immediately
browser.waitForUrl '/products', {
  start: 30
  count: 15
}
```

#### browser.getPath()

Returns the current path ('/some/route') of the page.
This is different from `getUrl` because only
the path portion of the full url is returned.

```coffee
assert = require 'assertive'
browser.navigateTo '/products'
path = browser.getPath()
assert.equal '/products', path
```

#### browser.waitForPath(path, timeout=5000)

Waits `timeout` milliseconds
for the browser to be
at the specified `path`.

`path` can be a String, or a Regular Expression.

```coffee
# waits up to one second for path to be "/products"
browser.waitForPath('/products', 1000)
```

#### browser.getPageTitle()

Returns the current page title.

```coffee
title = browser.getPageTitle()
```

#### browser.getPageSource()

Returns the current page's html source.
Using this method usually means
that you are trying to test something
that can be done without a browser.
Consider writing a simpler test.

```coffee
assert = require 'assertive'
source = browser.getPageSource()
assert.matches /body/, source
```

Note that if the browser is presenting
something like an XML or JSON response,
this method will return
the presented HTML,
not the original XML or JSON response.
If you need to simply test such a response,
use a simpler test that
doesn't involve a browser.

#### browser.getPageSize()

Returns the current window's page size
as an object with height and width properties
in pixels.

```coffee
size = browser.getPageSize()
assert.equal 600, size.height
assert.equal 800, size.width
```

This can be useful for responsive UI testing
when combined with `browser.setPageSize`.
Testium defaults the page size to
`height: 768` and `width: 1024`.

#### browser.setPageSize({height, width})

Sets the current window's page size
in pixels.

```coffee
browser.setPageSize({height: 400, width: 200})
# page has resized to a much smaller screen

size = browser.getPageSize()
assert.equal 400, size.height
assert.equal 200, size.width
```

This can be useful for responsive UI testing.

#### browser.getScreenshot()

Returns screenshot as a base64 encoded PNG.

```coffee
browser.navigateTo '/products'
screenshot = browser.getScreenshot()
```

#### browser.click(cssSelector)

Finds an [Element](#element)
based on the `cssSelector`
and clicks it.

```coffee
browser.click('.menu-button')

# is the same as

button = browser.getElement('.menu-button')
button.click()
```

#### browser.setValue(cssSelector, value)

*Alias: browser.clearAndType*

Set's the [Element](#element)'s value
to `value` found by the given `cssSelector`.

```coffee
browser.setValue('.first-name', 'John')
browser.setValue('.last-name', 'Smith')
browser.click('.submit')
```

#### browser.clear(cssSelector)

Clears the input [Element](#element)
found by the given `cssSelector`.

```coffee
assert = require 'assertive'
browser.type('.search', 'puppies')
browser.clear('.search')
searchValue = browser.getElement('.search').get('value')
assert.falsey searchValue
```

#### browser.clearAndType(cssSelector, value)

Clears the input [Element](#element)
found by the given `cssSelector`,
then sends `value` to it.

```coffee
browser.clearAndType('.search', 'kittens')

# is the same as

browser.clear('.search')
browser.type('.search', 'kittens')
```

#### browser.evaluate( [String|Function] clientFunction )

Executes the given JavaScript in the browser.
The argument can be a String or a Function.

Note that the client-side function
will not have access to server-side values.

**string**

It must contain a return statement
in order to get a value back.

```js
// JavaScript
var clientFunction = "return document.querySelector('.menu').style;";
style = browser.evaluate(clientFunction);
```

```coffee
# CoffeeScript

# the client-side string must still be JavaScript
clientFunction = "return document.querySelector('.menu').style;"
style = browser.evaluate(clientFunction)
```

**function**

```js
// JavaScript
var clientFunction = function(){
  // does not have access to the closure
  // because this will be run on the client
  return document.querySelector('.menu').style;
};
style = browser.evaluate(clientFunction);
```

```coffee
# CoffeeScript

# the client-side function can be written here
# as CoffeeScript because it will
# be converted for you
clientFunction = ->
  document.querySelector('.menu').style
style = browser.evaluate(clientFunction)
```

#### browser.evaluate(args..., function(args...))

Same as above,
but marshals the `args` as JSON
and passes them to the function
in the given order.

```coffee
hash = browser.evaluate 'hash', (prop) -> window.location[prop]

# is the same as

clientFunction = -> window.location['hash']
hash = browser.evaluate(clientFunction)
```

#### browser.setCookie(Cookie)

Sets a [Cookie](#cookie) on the current page's domain.

You can set cookies before loading your first page.
Testium tells the browser to load a blank page
at `/` so that cookies can be set
before loading a real page.

```coffee
cookie =
  name: 'userId'
  value: '3'
browser.setCookie(cookie)
```

#### browser.setCookies([Cookie])

Sets all [Cookie](#cookie) objects
in the array.

```coffee
cookies = [
  {name: 'userId', value: '3'}
  {name: 'dismissedPopup', value: 'true'}
]
browser.setCookies(cookies)

# is the same as

cookies.forEach (cookie) ->
  browser.setCookie(cookie)
```

#### browser.getCookie(name)

Returns the [Cookie](#cookie) visible
to the current page with `name`.

```coffee
assert = require 'assertive'
userIdCookie = browser.getCookie('userId')
assert.equal 3, userIdCookie.value
```

#### browser.getCookies()

Returns all [Cookie](#cookie) objects
visible to the current page.

```coffee
cookies = browser.getCookies()
```

#### browser.clearCookies()

Deletes all [Cookie](#cookie) objects
visible to the current page.

```coffee
assert = require 'assertive'
browser.clearCookies()
cookies = browser.getCookies()
assert.equal 0, cookies.length
```

#### browser.clearCookie()

Delete a [Cookie](#cookie) by `name`
that is visible to the current page.

```coffee
assert = require 'assertive'
browser.setCookie(name: 'userId', value: '3')
browser.clearCookie('user')
cookies = browser.getCookies()
assert.equal 0, cookies.length
```

#### browser.getStatusCode()

Returns the response status code
for the current page.

This uses an internal proxy
to store the response status code.
Therefore, this method does not currently work
when navigating to absolute urls.

```coffee
browser.navigateTo '/products'
statusCode = browser.getStatusCode()
```

#### browser.getHeaders(name)

Returns the value of the response header
with the provided name.

This uses an internal proxy
to store the response headers.
Therefore, this method does not currently work
when navigating to absolute urls.

```coffee
browser.navigateTo '/products'
contentLength = browser.getHeader('Content-Length')
```

#### browser.getHeaders()

Returns all response headers
for the current page.

```coffee
browser.navigateTo '/products'
allHeaders = browser.getHeaders()
```

#### browser.getConsoleLogs(logLevel='all')

Returns all log events with
`logLevel` (all/log/warn/error/debug)
since the last time this method was called.

```coffee
errorLogs = browser.getConsoleLogs('error')
```

Warning: No browser appears to implement this
exactly according to the spec.
It's best used as extra information,
not something you depend on to always work
in the same way.

#### browser.switchToDefaultFrame()

Switch focus to the default frame
(i.e., the actual page).

```coffee
browser.switchToFrame('some-frame')
browser.click('#some-button-in-frame')
browser.switchToDefaultFrame()
```

#### browser.switchToFrame(id)

Switch focus to the frame
with name or id `id`.

```coffee
browser.switchToFrame('some-frame')
browser.click('#some-button-in-frame')
browser.switchToDefaultFrame()
```

#### browser.switchToDefaultWindow()

Switch focus to the window
that was most recently referenced
by `navigateTo`.

```coffee
browser.navigateTo '/path'
browser.click '#open-popup'
browser.switchToWindow('popup1')
browser.click '#some-button-in-popup'
browser.closeWindow()
browser.switchToDefaultWindow()
```

#### browser.switchToWindow(name)

Switch focus to the window with name `name`.

```coffee
browser.navigateTo '/path'
browser.click '#open-popup'
browser.switchToWindow('popup1')
browser.click '#some-button-in-popup'
browser.closeWindow()
browser.switchToDefaultWindow()
```

#### browser.closeWindow()

Close the currently focused window.

```coffee
browser.click '#open-popup'
browser.switchToWindow('popup1')
browser.closeWindow()
browser.switchToDefaultWindow()
```

The name used to identify
the popup can be set in the code
used to create it.
Remember that the signature
looks like:
`window.open(path, popupName, popupOptions)`.


#### browser.close(callback)

Closes the Testium session
and the browser attached to it.
Calls the callback
when everything is torn down.

```coffee
browser.close ->
  console.log 'all done!'
```

### Element

An element object
has the following properties.

```coffee
element = browser.getElement(selector)
```

Note: `selector` can be anything
[WebDriver's CSS Selector](http://www.w3.org/TR/2013/WD-webdriver-20130117/#css-selectors)
can accept.
Where supported by browsers,
this is equivalent to `document.querySelectorAll(selector)`.
That means that advanced CSS selectors used by jQuery
are not always supported.
To debug, try your selector in the
browser developer tools
with `document.querySelectorAll(mySelector)`.

#### element.get(attribute)

Returns the element's specified attribute,
which can be `text`.
Note that WebDriver (and therefore testium)
will not return text of hidden elements.

```coffee
value = element.get('value')
```

#### element.click()

Calls click on the element.

```coffee
element.click()
```

#### element.isVisible()

Returns `true` if the element is visible.

#### element.type(strings...)

Sends `strings...` to the input element.

#### element.clear()

Clears the input element.

### Alert

This API allows you to interact with
alert, confirm, and prompt dialogs.

Some browsers, notable phantomjs,
don't support this part of the WebDriver spec.
You can guard against this by checking
the [Capabilities](#capabilities) object.

```coffee
describe 'alert-based tests', ->
  if !getBrowser().capabilities.handlesAlerts
    browserName = getBrowser().capabilities.browserName
    xit "skipping tests because browser #{browserName} doesn't support alerts"
  else
    # alert-based tests
```

#### browser.getAlertText()

Gets the text of a visible
alert, prompt, or confirm dialog.

```coffee
alertText = browser.getAlertText()
```

#### browser.acceptAlert()

Accepts a visible
alert, prompt, or confirm dialog.

```coffee
browser.acceptAlert()
```

#### browser.dismissAlert()

Dismisses a visible
alert, prompt, or confirm dialog.

```coffee
browser.dismissAlert()
```

#### browser.typeAlert(value)

Types into a visible prompt dialog.

```coffee
browser.typeAlert('')
```

### Assertions

#### browser.assert.elementHasText( [docString,] selector, textOrRegex)

Asserts that the element at `selector`
contains `textOrRegex`.
Returns the element.

Throws exceptions if `selector`
doesn't match a single node,
or that node does not contain the given `textOrRegex`.

Allows an optional extra _initial_ docstring argument,
for semantic documentation about the test
when the assertion fails.

```coffee
browser.assert.elementHasText('.user-name', 'someone')

# is the same as

assert = require 'assertive'
userName = browser.getElement('.user-name')
assert.equal 'someone', userName.get('text')
```

#### browser.assert.elementLacksText( [docString,] selector, textOrRegex)

Asserts that the element at `selector`
does not contain `textOrRegex`.
Returns the element.

Inverse of `assert.elementHasText`.

#### browser.assert.elementHasValue( [docString,] selector, textOrRegex)

Asserts that the element at `selector`
does not have the value `textOrRegex`.
Returns the element.

Throws exceptions if `selector`
doesn't match a single node,
or that node's value is not `textOrRegex`.

Allows an optional extra _initial_ docstring argument,
for semantic documentation about the test
when the assertion fails.

```coffee
browser.assert.elementHasValue('.user-name', 'someone else')

# is the same as

assert = require 'assertive'
userName = browser.getElement('.user-name')
assert.equal 'someone else', userName.get('value')
```

#### browser.assert.elementLacksValue(selector, textOrRegex)

Asserts that the element at `selector`
does not have the value `textOrRegex`.
Returns the element.

Inverse of `assert.elementHasValue`.

#### browser.assert.elementHasAttributes( [docString,] selector, attributesObject)

Asserts that the element at `selector`
contains `attribute:value` pairs specified by attributesObject.
Returns the element.

Throws exceptions if `selector`
doesn't match a single node,
or that node does not contain the given `attribute:value` pairs.

Allows an optional extra _initial_ docstring argument,
for semantic documentation about the test
when the assertion fails.

```coffee
browser.assert.elementHasAttributes('.user-name', {text: 'someone', name: 'username'})
```

#### browser.assert.elementIsVisible(selector)

Asserts that the element at `selector`
is visible.
Returns the element.

Throws exceptions if selector doesn't exist
or is not visible.

```coffee
browser.assert.elementIsVisible('.user-name')

# is the same as

assert = require 'assertive'
userName = browser.getElement('.user-name')
assert.truthy userName.isVisible()
```

#### browser.assert.elementNotVisible(selector)

Asserts that the element at `selector`
is not visible.
Returns the element.

Inverse of `assert.elementIsVisible`.


#### browser.assert.elementExists(selector)

Asserts that the element at `selector` exists.
Returns the element.

Throws exceptions if selector doesn't exist.

```coffee
browser.assert.elementExists('.user-name')
```

#### browser.assert.elementDoesntExist(selector)

Asserts that the element at `selector`
doesn't exist.
Returns the element.

Inverse of `assert.elementExists`.

#### browser.assert.httpStatus(statusCode)

Asserts that the most recent
response status code is `statusCode`.

```coffee
browser.navigateTo '/products'
browser.assert.httpStatus(200)
```

This is especially useful
as a method to short circuit
test failures.

```coffee
describe 'products', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/products'

    # if this fails, the three tests below
    # will not be run, saving output noise
    @browser.assert.httpStatus 200

  it 'works 1', ->
  it 'works 2', ->
  it 'works 3', ->
```

#### browser.assert.imgLoaded( [docString,] selector)

Asserts that the image element at `selector`
has both loaded and been decoded successfully.

Allows an optional extra _initial_ docstring argument,
for semantic documentation
about the test when the assertion fails.

```coffee
browser.assert.imgLoaded '.logo'
```

### Capabilities

This is an object based on
the [WebDriver capabilities](https://code.google.com/p/selenium/wiki/JsonWireProtocol#Capabilities_JSON_Object)
object.
It includes additional inferences
about the capabilities of the attached browser
stored under the `testium` key.

#### capabilities.testium.consoleLogs

The browser can support
three different levels of retrieving
`console[log,warn,debug,error]`
events.

**none**

The method `browser.getConsoleLogs` itself
is not even supported.
Do not call it without either
(1) making sure you will never use
a browser that doesn't support it or
(2) guarding against it by checking
the capabilities object first.

**basic**

The method `browser.getConsoleLogs` works,
but it assumes that all log events are of type `log`,
regardless of their actual values.
That means that `console.error()` calls on the client
will return as a `console.log` event by this method.

**all**

The method `browser.getConsoleLogs` works
entirely as documented.

```coffee
if browser.capabilities.consoleLogs != 'none'
  logs = browser.getConsoleLogs()
```

### Cookie

A Cookie object
has the following properties.

```coffee
Cookie = {
  name
  value
  path = '/'
  domain = #{current_page_domain}
  expiry
}
```
