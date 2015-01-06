injectBrowser = require '../../mocha'
assert = require 'assertive'

describe 'ssl/tls', ->
  before injectBrowser()

  it 'TLS is supported', ->
    @browser.navigateTo 'https://www.howsmyssl.com/a/check'
    raw = @browser.getElement('pre').get('text')
    sslReport = JSON.parse(raw)
    assert.match /^TLS/, sslReport.tls_version

