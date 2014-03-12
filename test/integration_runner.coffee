{rmdirSync, existsSync, readdirSync, statSync, unlinkSync} = require 'fs'
mkdirp = require 'mkdirp'
testApp = require './app'
testium = require '../lib/index'
{series} = require 'async'

TEST_DIRECTORY = "#{__dirname}/integration"
LOG_DIRECTORY = "#{__dirname}/integration_log"
SCREENSHOT_DIRECTORY = "#{LOG_DIRECTORY}/screenshots"
DEFAULT_BROWSERS = [ 'phantomjs' ]

deleteFolderRecursive = (path) ->
  return unless existsSync path

  readdirSync(path).forEach (file, index) ->
    curPath = path + "/" + file
    if statSync(curPath).isDirectory()
      deleteFolderRecursive curPath
    else # delete file
      unlinkSync curPath

  rmdirSync(path)

ensureEmpty = (path) ->
  deleteFolderRecursive path
  mkdirp.sync path

runTests = (callback) ->
  testBrowser = (browser) -> (browserTested) ->
    console.error "\nTesting against: #{browser}\n"
    options =
      tests: TEST_DIRECTORY
      screenshotDirectory: SCREENSHOT_DIRECTORY
      logDirectory: LOG_DIRECTORY
      appDirectory: "#{__dirname}/.."
      applicationPort: 4003
      browser: browser
      http:
        timeout: 60000
        connectTimeout: 20000 # TODO: doesn't change the timeout
    testium.run options, browserTested

  browserTests = browsers.map testBrowser
  series browserTests, callback

exit = (error) ->
  console.error error.stack if error?
  process.exit(-1)

process.on 'uncaughtException', exit

browsers = DEFAULT_BROWSERS
if process.env.BROWSER
  browsers = process.env.BROWSER.split ','

ensureEmpty LOG_DIRECTORY
ensureEmpty SCREENSHOT_DIRECTORY

testApp.listen 4003, ->
  runTests (err, failedTestCounts) ->
    throw err if err

    failedTests = 0
    browsers.forEach (browser, index) ->
      failedCount = failedTestCounts[index]
      console.error "Using #{browser}: #{failedCount} failed test(s)"
      failedTests += failedCount

    testApp.kill ->
      console.log '====================================='
      console.error "All browsers: #{failedTests} failed test(s)"
      code = if failedTests == 0 then 0 else 1
      process.exit code
