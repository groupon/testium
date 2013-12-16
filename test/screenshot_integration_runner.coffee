{rmdirSync, existsSync, readdirSync, statSync, unlinkSync} = require 'fs'
{contains} = require 'underscore'
mkdirp = require 'mkdirp'
assert = require 'assertive'
testApp = require './app'
testium = require '../lib/index'

TEST_DIRECTORY = "#{__dirname}/screenshot_integration"
LOG_DIRECTORY = "#{__dirname}/screenshot_integration_log"
SCREENSHOT_DIRECTORY = "#{LOG_DIRECTORY}/screenshots"

deleteFolderRecursive = (path) ->
  return unless existsSync path

  readdirSync(path).forEach (file,index) ->
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
  options =
    tests: TEST_DIRECTORY
    screenshotDirectory: SCREENSHOT_DIRECTORY
    logDirectory: LOG_DIRECTORY
    appDirectory: "#{__dirname}/.."
    applicationPort: 4003
    browser: 'phantomjs'

  console.error "\n\n========= Expecting two errors: ========="
  testium.run options, callback

exit = (error) ->
  console.error error if error?

  testium.cleanup (error) ->
    console.error error if error?
    process.exit(-1)

process.on 'uncaughtException', exit

ensureEmpty LOG_DIRECTORY
ensureEmpty SCREENSHOT_DIRECTORY

testApp.listen 4003, ->
  runTests (err, failedCount) ->
    throw err if err

    console.error "========= Expecting no more errors =========\n\n"

    exitCode = 0
    try
      assert.equal "The suite contains 2 failed tests", 2, failedCount

      screenshotFiles = readdirSync SCREENSHOT_DIRECTORY
      assert.equal "Two screenshots made", 2, screenshotFiles?.length
      assert.expect contains(screenshotFiles, "my_test.png")
      assert.expect contains(screenshotFiles, "some_sPecial_chars.png")

      console.error "SUCCESS: The expected screenshots were made."
    catch assertionError
      exitCode = 1
      console.error assertionError.stack

    deleteFolderRecursive SCREENSHOT_DIRECTORY
    testApp.kill ->
      process.exit exitCode
