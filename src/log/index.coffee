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

fs = require 'fs'
mkdirp = require 'mkdirp'
logError = require './error'

DEFAULT_LOG_DIRECTORY = "#{__dirname}/../../log"

createLog = (path) ->
  fs.createWriteStream path, {flags: 'w', encoding: 'utf-8'}

module.exports = (logDirectory=DEFAULT_LOG_DIRECTORY) ->
  mkdirp.sync logDirectory
  logStream = createLog "#{logDirectory}/webdriver.log"
  verboseLogStream = createLog "#{logDirectory}/webdriver-verbose.log"

  stringifyBuffers = (key, value) ->
    return value unless value instanceof Buffer
    """Buffer("#{ value.toString() }")"""

  log = (message) ->
    message = message + '\n'
    logStream.write(message)
    verboseLogStream.write(message)

  log.error = logError

  log.response = (response) ->
    response = JSON.stringify response, stringifyBuffers
    verboseLogStream.write "----> #{response}"
    if response.data?.length
      verboseLogStream.write(response.data.toString())

    verboseLogStream.write('\n')

  log.flush = (callback) ->
    oneDone = false

    logStream.end ->
      if oneDone
        return callback()
      oneDone = true

    verboseLogStream.end ->
      if oneDone
        return callback()
      oneDone = true

  log
