# Testium

Testium is a testing platform focused on providing a simple,
but effective,
platform for testing your code
in different browsers (via Selenium)
and headlessly (via PhantomJS).
It uses [webdriver-http-sync](https://github.com/groupon/webdriver-http-sync)
in order to communicate
(using the WebDriver protocol)
with a selenium server.

Keep up to date with changes
by checking the
[releases](https://github.com/groupon-testium/testium/releases).

[Demo Video](https://www.youtube.com/watch?v=qmPlM_SqZes)

## Example

A simple test using [assertive](https://github.com/groupon/assertive).

```coffeescript
{getBrowser} = require 'testium'
assert = require 'assertive' # or whatever assert library you prefer

describe 'browse', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/my-account'
    @browser.assert.httpStatus 200

  it 'is serving up gzipped content', ->
    assert.equal 'gzip', @browser.getHeader('Content-Encoding')
```

For help debugging your tests,
check out
[the wiki page](https://github.com/groupon/testium/wiki/Debugging-Your-Tests).

## Getting Started

Install Testium by running `npm install --save testium`.

Then, you need to require it and run it, like so!

```coffeescript
testium = require 'testium'

testOptions =
  tests: "#{__dirname}/test/integration" #string or array of absolute and/or directory paths and/or glob patterns
  applicationPort: 4000 # used to resolve relative paths in navigateTo calls
  browser: 'phantomjs' # chrome | firefox | internet explorer

testium.run testOptions, (error, exitCode) ->
  # error might have an extra property `.stderr`
  # that captures the stderr of a crashed
  # internal process

  # handle result
```

### Detailed Setup

Testium might require that you install some
system-level libraries.

**required**

- **libcurl** (for sync http)
<br>[Ubuntu] `sudo apt-get install libcurl4-openssl-dev`
<br>[OS X] `brew install curl`
- **java 7+** (for selenium)
- **Node.js 0.10+** (for [testium@1.4.0](https://github.com/groupon-testium/testium/releases/tag/v1.4.0)+)

**optional**

- **libpng** (for image diffing)
<br>[Ubuntu] `sudo apt-get install libpng-dev`
<br>[OS X] `brew install libpng`
- **phantomjs 1.9.7+** (for headless running)

Below are all of the options you can specify
with their defaults as an example.

```coffeescript
testium = require 'testium'
testOptions =
  beforeTests: "#{__dirname}/test/setup.coffee" # custom test setup script
  tests: "#{__dirname}/test/integration" # string or array of strings containing: glob pattern or an [absolute|relative] [file|directory]
  applicationPort: 4000 # used to resolve relative paths in navigateTo calls
  screenshotDirectory: "#{__dirname}/test/failed_screenshots"
  browser: 'phantomjs' # chrome | firefox | internet explorer
  appDirectory: "#{__dirname}/.." # allows relative paths to files/dirs to test
  seleniumServer: 'http://localhost:9999/wd/hub' # optional external selenium server
  javaHeapSize: 256 # optional max java heap size; in megabytes
  logDirectory: "#{__dirname}/log" # directory for testium log files
  http:
    timeout: 60000
    connectTimeout: 20000
  mochaOptions:
    reporter: 'spec' # the screenshot on failure future will stop working if you set this
    timeout: 20000
    slow: 4000

testium.run testOptions, (error, exitCode) ->
  # handle result
```

If the `seleniumServer` option is not specified,
the first test run will download
the latest selenium standalone server
and chromedriver.

## Testium Command-Line Tool

### Updating Selenium

When you run your first batch of tests,
testium ensures that you have the latest
selenium standalone server and chromedriver.

If you want to make sure those
continue to be up to date,
you can use the command-line tool!

```
$ ./node_modules/.bin/testium --update-selenium
[testium] grabbing selenium standalone server 2.39.0
[testium] grabbing selenium chromedriver 2.8
Up to date!
```

### Interactive Console

Testium provides an interactive CoffeeScript console
as a bin stub.
It creates a browser
and mixes the methods of that browser
into the global scope.

You can use it like so!

```
$ ./node_modules/.bin/testium
%> navigateTo 'google.com'
%> element = getElement 'input[name="q"]'
%> element.type 'puppies\n'
```

And the browser will navigate to `google.com`,
find the search box,
and type `puppies\n` into it.
You should now see search results for puppies.

This is useful for testing out your commands
before setting up an actual test.

## Testium API

The complete description
can be found at
[API.md](API.md).

`browser = getBrowser()`

### Browser

Method | Description
:----- | :----------
`browser.navigateTo(url, options)` | Navigates the browser to the specificed relative or absolute url with options such as headers.
`browser.refresh()` | Refresh the current page.
`browser.capabilities` | Is an object describing the [WebDriver capabilities](https://code.google.com/p/selenium/wiki/JsonWireProtocol#Capabilities_JSON_Object) that the current browser supports.
`browser.getElement(cssSelector)` | Finds an element on the page using the `cssSelector` and returns an Element.
`browser.getElements(cssSelector)` | Finds all elements on the page using the `cssSelector` and returns an array of Elements.
~~`browser.waitForElement(cssSelector, timeout=3000)`~~ | **Deprecated** *(synonym for `browser.waitForElementVisible(cssSelector, timeout=3000)`*
`browser.waitForElementVisible(cssSelector, timeout=3000)` | Waits for the element at `cssSelector` to exist and be visible, then returns the Element. Times out after `timeout` ms.
`browser.waitForElementExist(cssSelector, timeout=3000)` | Waits for the element at `cssSelector` to exist, then returns the Element. Times out after `timeout` ms. Visibility is not considered.
`browser.getUrl()` | Returns the current url ('http://localhost:1234/some/route') of the page.
`browser.waitForUrl(url, timeout=5000)` | Waits `timeout` ms for the browser to be at the specified `url`.
`browser.waitForUrl(url, query, timeout=5000)` | Waits `timeout` ms for the browser to be at the specified `url` with query parameters per the `query` object.
`browser.getPath()` | Returns the current path ('/some/route') of the page.
`browser.waitForPath(path, timeout=5000)` | Waits `timeout` ms for the browser to be at the specified `path`.
`browser.getPageTitle()` | Returns the current page title.
`browser.getPageSource()` | Returns the current page's html source.
`browser.getPageSize()` | Returns the current window's size.
`browser.setPageSize({height, width})` | Sets the current window's size.
`browser.getScreenshot()` | Returns screenshot as a base64 encoded PNG.
`browser.click(cssSelector)` | Calls Click on the Element found by the given `cssSelector`.
`browser.type(cssSelector, value)` | Sends `value` to the input Element found by the given `cssSelector`.
`browser.setValue(cssSelector, value)` | Set's the Element's value at `cssSelector` to `value`.
`browser.clear(cssSelector)` | Clears the input Element found by the given `cssSelector`.
`browser.clearAndType(cssSelector, value)` | Clears the input Element found by the given `cssSelector`, then sends `value` to it.
`browser.evaluate(javascriptString)` | Executes the given javascript. It must contain a return statement in order to get a value back.
`browser.evaluate(function)` | Returns the result of the given function, invoked on the webdriver side (so you can not bind its `this` object or access context variables via lexical closure).
`browser.evaluate(args..., function(args...))` | Same as above, but marshals the args as JSON and passes them to the function in the given order. E g: `browser.evaluate 'hash', (prop) -> window.location[prop]` would return the current url fragment.
`browser.setCookie(Cookie)` | Sets a cookie on the current page's domain. `Cookie = { name, value, path='/' }`
`browser.setCookies([Cookie])` | Sets all cookies in the array. `Cookie = { name, value, path='/' }`
`browser.getCookie(name)` | Returns the cookie visible to the current page with `name`.
`browser.getCookies()` | Returns all cookies visible to the current page.
`browser.clearCookies()` | Deletes all cookies visible to the current page.
`browser.getStatusCode()` | Returns the response status code for the current page.
`browser.getHeader(name)` | Returns the value of the response header with the provided name.
`browser.getHeaders()` | Returns all response headers for the current page.
`browser.getConsoleLogs(logLevel='all')` | Returns all log events with `logLevel` (log/warn/error/debug) since the last time this method was called. Warning: Each browser implements this differently against the WebDriver spec.
`browser.switchToDefaultFrame()` | Switch focus to the default frame (i.e., the actual page).
`browser.switchToFrame(id)` | Switch focus to the frame with name or id `id`.
`browser.switchToDefaultWindow()` | Switch focus to the window that was most recently referenced by `navigateTo`. Useful when interacting with popup windows.
`browser.switchToWindow(name)` | Switch focus to the window with name `name`.
`browser.close(callback)` | Closes the Testium session.

### Alert

Method | Description
:----- | :----------
`browser.alert.getText()` | Gets the text of a visible alert, prompt, or confirm dialog.
`browser.alert.accept()` | Accepts a visible alert, prompt, or confirm dialog.
`browser.alert.dismiss()` | Dismisses a visible alert, prompt, or confirm dialog.
`browser.alert.type(value)` | Types into a visible prompt dialog.

Note: Alerts effectively don't work when running with PhantomJS.
`getText()` will throw an error and the others will just silently not work.
If you must test with PhantomJS you can work around this by
stubbing the `alert`, `confirm`, and `prompt` global methods
in your client-side javascript.
Below is an example.

```coffeescript
# Stub alert
@browser.evaluate 'return window.alert = function() { };'

# Stub confirmation
desiredValue = true
@browser.evaluate "return window.confirm = function() { return #{desiredValue}; };"

# Stub prompt
desiredValue = 'foo'
@browser.evaluate "return window.prompt = function() { return \'#{desiredValue}\'; };"
```

### Assertions

Method | Description
:----- | :----------
`browser.assert.elementHasText(selector, textOrRegex)` | Throws exceptions if selector doesn't match a single node, or that node does not contain the given `textOrRegex`. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementLacksText(selector, textOrRegex)` | Throws exceptions if selector doesn't match a single node, or that node does contain the given `textOrRegex`. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementHasValue(selector, textOrRegex)` | Throws exceptions if selector doesn't match a single node, or that node's value does not contain the given `textOrRegex`. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementLacksValue(selector, textOrRegex)` | Throws exceptions if selector doesn't match a single node, or that node's value does contain the given `textOrRegex`. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementIsVisible(selector)` | Throws exceptions if selector doesn't exist or is not visible. Returns the element.
`browser.assert.elementNotVisible(selector)` | Throws exceptions if selector doesn't exist or is visible. Returns the element.
`browser.assert.elementExists(selector)` | Throws exceptions if selector doesn't exist. Returns the element.
`browser.assert.elementDoesntExist(selector)` | Throws exceptions if selector exists.
`browser.assert.httpStatus(statusCode)` | Throws exceptions if current status code is not equal to the provided statusCode.
`browser.assert.imgLoaded(selector)` | Throws exceptions if selector doesn't match a single `<img>` element that has both loaded and been decoded successfully. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails.
`browser.assert.imagesMatch(image1, image2, tolerance=0)` | Throws exceptions if the images don't match within the given tolerance. Warning: this method is experimental and slow. You can use `@slow(4000)` in tests to notify mocha of this.

### Element

`element = browser.getElement(selector)`

Note: `selector` can be anything
[WebDriver's CSS Selector](http://www.w3.org/TR/2013/WD-webdriver-20130117/#css-selectors)
can accept.
Where supported by browsers,
this is equivalent to `document.querySelectorAll(selector)`.

Method | Description
:----- | :----------
`element.get(attribute)` | Returns the element's specified attribute, which can be `text`. Note that WebDriver (and therefore testium) will not return text of hidden elements.
`element.click()` | Calls click on the element.
`element.isVisible()` | Returns `true` if the element is visible.
`element.type(strings...)` | Sends `strings...` to the input element.
`element.clear()` | Clears the input element.

## Contributing

If you'd like to help make testium better,
please check out:

* [CONTRIBUTING.md](CONTRIBUTING.md)
* [Roadmap](https://github.com/groupon/testium/wiki/Roadmap)
* [Under the Hood](https://github.com/groupon/testium/wiki/Under-the-Hood)

If you have questions,
you can contact the author at: <br>
[@endangeredmassa](https://twitter.com/endangeredmassa) <br>
[smassa@groupon.com](mailto:smassa@groupon.com)
