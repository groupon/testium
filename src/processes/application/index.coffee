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

async = require 'async'
readPackageJson = require 'read-package-json'
debug = require('debug')('testium:processes:application')
{defaults} = require 'lodash'

{spawnServer} = require '../server'
{findOpenPort, isAvailable} = require '../port'
initLogs = require '../../logs'

NO_LAUNCH_COMMAND_ERROR =
  'Not launch command found, please add scripts.start to package.json'

getLaunchCommand = (config, callback) ->
  if config.app.command
    return callback null, config.app.command

  debug 'Trying to use package.json:scripts.start'
  pkgJsonPath = "#{config.root}/package.json"
  readPackageJson pkgJsonPath, (error, pkgJson) ->
    return callback(error) if error?

    debug 'Loaded from package json', pkgJson.scripts?.start

    unless pkgJson.scripts?.start
      return callback new Error NO_LAUNCH_COMMAND_ERROR

    callback null, pkgJson.scripts.start

isTrulyTrue = (value) ->
  value == true || value == '1' || value == 'true'

spawnApplication = (config, callback) ->
  {launch, app: {timeout}} = config
  launch = isTrulyTrue launch

  unless launch
    return isAvailable config.app.port, (error, available) ->
      unless available
        return callback null, {
          baseUrl: "http://127.0.0.1:#{config.app.port}"
        }
      callback new Error "App not listening on #{config.app.port}"

  logs = initLogs config

  async.auto {
    port: (done) ->
      {port} = config.app
      isAvailable port, (error, available) ->
        return done(null, port) if available
        done new Error "Something is already listening on #{port}"

    launchCommand: (done) ->
      getLaunchCommand config, done

    app: [ 'port', 'launchCommand', (done, {port, launchCommand}) ->
      args = launchCommand.split /[\s]+/g
      cmd = args.shift()
      debug 'Launching application', cmd, args

      env = defaults {
        NODE_ENV: 'test'
        PORT: port
        PATH: "./node_modules/.bin:#{process.env.PATH}"
      }, process.env

      opts = {port, env, timeout}
      spawnServer logs, 'application', cmd, args, opts, done
    ]
  }, (error, {app}) ->
    callback error, app

module.exports = spawnApplication
