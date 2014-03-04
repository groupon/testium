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

glob = require 'glob'
readr = require 'readr'
{isArray, flatten} = require 'underscore'
{join} = require 'path'
{statSync} = require 'fs'

module.exports.findAll = (patterns, appDirectory) ->
  return if !patterns

  unless isArray patterns
    patterns = [patterns]

  patterns = resolvePaths patterns, appDirectory
  flatten patterns.map(getFilesForPattern)

getFilesForPattern = (pattern) ->
  patternType = getPatternType pattern

  if patternType == 'file'
    [pattern]
  else if patternType == 'directory'
    getPathsForDirectory(pattern)
  else
    glob.sync(pattern)

getPathsForDirectory = (directory) ->
  readr.getPathsSync(directory, {extension: '{js,coffee}'}).map (metadata) ->
    metadata.path

resolvePaths = (paths, appDirectory) ->
  paths.map (path) ->
    if path[0] == '/'
      path
    else
      join appDirectory, path

getPatternType = (pattern) ->
  try
    stats = statSync(pattern)
  catch
    return 'glob'

  if stats.isFile() then return 'file'
  if stats.isDirectory() then return 'directory'

  'glob'
