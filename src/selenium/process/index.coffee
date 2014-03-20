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

DEFAULT_LOG_DIRECTORY = "#{__dirname}/../../../log"

mkdirp = require 'mkdirp'
async = require 'async'
startSelenium = require './selenium'
startProxy = require './proxy'
createLog = require './create_log'

module.exports = (seleniumServerUrl, javaHeapSize, logDirectory, applicationPort, callback) ->
  logDirectory ?= DEFAULT_LOG_DIRECTORY
  mkdirp.sync logDirectory

  seleniumLog = createLog("#{logDirectory}/selenium.log")
  proxyLog = createLog("#{logDirectory}/proxy.log")

  tasks =
    proxy: startProxy(applicationPort, proxyLog)

  if !seleniumServerUrl
    tasks.selenium = startSelenium(seleniumLog, javaHeapSize)

  # ignoring the first arg (error)
  # because it will short circuit the callback
  async.parallel tasks, (dummySlot, results) ->
    {proxy, selenium} = results
    error = selenium.error || proxy.error
    proxy = proxy.process
    selenium = selenium.process
    callback(error, {proxy, selenium})

