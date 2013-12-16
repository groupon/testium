# Testium

Testium is a testing platform focused on providing a simple,
but effective,
platform for testing your code in different browsers (via Selenium)
and headlessly (via PhantomJS).
It uses [webdriver-http-sync](https://github.com/groupon/webdriver-http-sync)
in order to communicate using the WebDriver protocol to a selenium server.

## Installing Testium

**Warning: There is an issue with npm where
`npm install testium` returns the wrong thing.
Please use `npm install testium@1.0.0` until
this issue has been resolved.**

On Ubuntu, you need to make sure you have libcurl installed.
`sudo apt-get install libcurl4-openssl-dev`

If you want to use the experimental image diffing,
you must have libpng installed.
`sudo apt-get install libpng-dev`

If you see `execvp(): No such file or directory`,
you may not have java installed.
You can install OpenJDK or JDK 7.

Install Testium by adding `"testium": "~1.0.0"` to your package.json
and running `npm install`.

Then, you need to require it and run it, like so!

```coffeescript
testium = require 'testium'
testOptions =
  beforeTests: "#{__dirname}/test/setup.coffee" # custom test setup script
  tests: "#{__dirname}/test/integration" #string or array of absolute and/or directory paths and/or glob patterns
  applicationPort: 4000
  screenshotDirectory: "#{__dirname}/test/failed_screenshots"
  browser: 'phantomjs' # chrome | firefox
  appDirectory: "#{__dirname}/.." # allows relative paths to files/dirs to test
  http:
    timeout: 60000
    connectTimeout: 20000
  mochaOptions:
    reporter: 'spec'
    timeout: 20000

testium.run testOptions, (error, exitCode) ->
  # handle result
```

## Example

Here's an example test.

```coffeescript
{getBrowser} = require 'testium'
assert = require 'assertive' # or whatever assert library you prefer

describe 'browse', ->
  before ->
    @browser = getBrowser()
    @browser.navigateTo '/browse/abbotsford'
    assert.equal 200, @browser.getStatusCode()

  it 'Server sets x-itier-host header', ->
    assert.equal 'Pull-Itier', @browser.getHeader('x-Application')
```

## Testium API

`browser = getBrowser()`

### Browser

Method | Description
:----- | :----------
`browser.navigateTo(url, options)` | Navigates the browser to the specificed relative or absolute url. If relative, the root is assumed to be `http://127.0.0.1:#{applicationPort}`, where `applicatioAnPort` is passed in to the options for `testium.runTests`. `options` can include a `headers` param with headers to pass along with the request.
`browser.refresh()` | Refresh the current page.
`browser.getElement(cssSelector)` | Finds an element on the page using the `cssSelector` and returns an Element.
`browser.getElements(cssSelector)` | Finds all elements on the page using the `cssSelector` and returns an array of Elements.
`browser.waitForElement(cssSelector, timeout=3000)` | Waits for the element at `cssSelector` to exist and be visible. Times out after `timeout` ms.
`browser.getUrl()` | Returns the current url ('http://localhost:1234/some/route') of the page.
`browser.waitForUrl(url, timeout=5000)` | Waits `timeout` ms for the browser to be at the specified `url`.
`browser.getPath()` | Returns the current path ('/some/route') of the page.
`browser.waitForPath(path, timeout=5000)` | Waits `timeout` ms for the browser to be at the specified `path`.
`browser.getPageTitle()` | Returns the current page title.
`browser.getPageSource()` | Returns the current page's html source.
`browser.getScreenshot()` | Returns screenshot as a base64 encoded PNG.
`browser.click(cssSelector)` | Calls Click on the Element found by the given `cssSelector`.
`browser.type(cssSelector, keys...)` | Sends `keys...` to the input Element found by the given `cssSelector`.
`browser.clear(cssSelector)` | Clears the input Element found by the given `cssSelector`.
`browser.clearAndType(cssSelector, keys...)` | Clears the input Element found by the given `cssSelector`, then sends `keys...` to it.
`browser.evaluate(javascriptString)` | Executes the given javascript. It must contain a return statement in order to get a value back.
`browser.evaluate(function)` | Returns the result of the given function, invoked on the webdriver side (so you can not bind its `this` object or access context variables via lexical closure).
`browser.evaluate(args..., function(args...))` | Same as above, but marshals the args as JSON and passes them to the function in the given order. E g: `browser.evaluate 'hash', (prop) -> window.location[prop]` would return the current url fragment.
`browser.setCookie(Cookie)` | Sets a cookie on the current page's domain. `Cookie = { name, value, path='/' }`
`browser.setCookies([Cookie])` | Sets all cookies in the array. `Cookie = { name, value, path='/' }`
`browser.getCookie(name)` | Returns the cookie visible to the current page with `name`.
`browser.getCookies()` | Returns all cookies visible to the current page.
`browser.clearCoookies()` | Deletes all cookies visible to the current page.
`browser.getStatusCode()` | Returns the response status code for the current page.
`browser.getHeader(name)` | Returns the value of the response header with the provided name.
`browser.getHeaders()` | Returns all response headers for the current page.
`browser.close(callback)` | Closes the Testium session.

### Alert

Method | Description
:----- | :----------
`browser.alert.getText()` | Gets the text of a visible alert, prompt, or confirm dialog.
`browser.alert.accept()` | Accepts a visible alert, prompt, or confirm dialog.
`browser.alert.dismiss()` | Dismisses a visible alert, prompt, or confirm dialog.
`browser.alert.type(keys...)` | Types into a visible prompt dialog.

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
`browser.assert.elementHasText(selector, text)` | Throws exceptions if selector doesn't match a single node, or that node does not contain the given text. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementLacksText(selector, text)` | Throws exceptions if selector doesn't match a single node, or that node does contain the given text. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementHasValue(selector, text)` | Throws exceptions if selector doesn't match a single node, or that node's value does not contain the given text. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementLacksValue(selector, text)` | Throws exceptions if selector doesn't match a single node, or that node's value does contain the given text. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails. Returns the element.
`browser.assert.elementIsVisible(selector)` | Throws exceptions if selector doesn't exist or is not visible.
`browser.assert.elementNotVisible(selector)` | Throws exceptions if selector doesn't exist or is visible.
`browser.assert.elementExists(selector)` | Throws exceptions if selector doesn't exist.
`browser.assert.elementDoesntExist(selector)` | Throws exceptions if selector exists.
`browser.assert.imgLoaded(selector)` | Throws exceptions if selector doesn't match a single `<img>` element that has both loaded and been decoded successfully. Allows an optional extra _initial_ docstring argument, for semantic documentation about the test when the assertion fails.
`browser.assert.imagesMatch(image1, image2, tolerance=0)` | Throws exceptions if the images don't match within the given tolerance. Warning: this method is experimental.

### Element

`element = browser.getElement(selector)`

Method | Description
:----- | :----------
`element.get(attribute)` | Returns the element's specified attribute, which can be `text`. Note that WebDriver (and therefore testium) will not return text of hidden elements.
`element.click()` | Calls click on the element.

