
/*
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
 */
var debug, extend, omit, portscanner, procCrashedError, procTimedoutError, spawn, spawnServer, waitFor, _ref;

spawn = require('child_process').spawn;

portscanner = require('portscanner');

_ref = require('lodash'), extend = _ref.extend, omit = _ref.omit;

debug = require('debug')('testium:processes');

procCrashedError = function(proc) {
  var message, _ref1;
  message = "Process \"" + proc.name + "\" crashed with code " + proc.exitCode + ".\nSee log at: " + proc.logPath;
  if (((_ref1 = proc.error) != null ? _ref1.length : void 0) > 0) {
    message += "\n" + (proc.error.trim());
  }
  return new Error(message);
};

procTimedoutError = function(proc, port, timeout) {
  var formatArguments, message, _ref1;
  formatArguments = function(args) {
    if (args == null) {
      args = [];
    }
    if (!args.length) {
      return '(no arguments)';
    }
    return args.join('\n           ');
  };
  message = "Process \"" + proc.name + "\" did not start in time.\n\nDebug info:\n* command: " + proc.launchCommand + "\n           " + (formatArguments(proc.launchArguments)) + "\n* cwd:     " + proc.workingDirectory + "\n* port:    " + port + "\n* timeout: " + timeout + "\n\nSee log at: " + proc.logPath;
  if (((_ref1 = proc.error) != null ? _ref1.length : void 0) > 0) {
    message += "\n" + (proc.error.trim());
  }
  return new Error(message);
};

waitFor = function(proc, port, timeout, callback) {
  var check, error, procName, startTime;
  if (proc.exitCode != null) {
    error = procCrashedError(proc);
    return callback(error);
  }
  procName = proc.name;
  startTime = Date.now();
  check = function() {
    debug('Checking for %s on port %s', procName, port);
    return portscanner.checkPortStatus(port, '127.0.0.1', function(error, status) {
      if (proc.exitCode != null) {
        error = procCrashedError(proc);
        return callback(error);
      }
      if ((error != null) || status === 'closed') {
        if ((Date.now() - startTime) >= timeout) {
          return callback(procTimedoutError(proc, port, timeout));
        }
        return setTimeout(check, 100);
      } else {
        return callback();
      }
    });
  };
  return check();
};

spawnServer = function(logs, name, cmd, args, opts, cb) {
  var port, timeout;
  port = opts.port, timeout = opts.timeout;
  if (timeout == null) {
    timeout = 1000;
  }
  return logs.openLogFile(name, 'w+', function(error, results) {
    var child, logHandle, logPath, spawnOpts;
    if (error != null) {
      return cb(error);
    }
    logHandle = results.fd, logPath = results.filename;
    spawnOpts = extend({
      stdio: ['ignore', logHandle, logHandle]
    }, omit(opts, 'port', 'timeout'));
    child = spawn(cmd, args, spawnOpts);
    child.baseUrl = "http://127.0.0.1:" + port;
    child.logPath = logPath;
    child.logHandle = logHandle;
    child.launchCommand = cmd;
    child.launchArguments = args;
    child.workingDirectory = spawnOpts.cwd;
    child.name = name;
    process.on('exit', function() {
      var err;
      try {
        return child.kill();
      } catch (_error) {
        err = _error;
        return console.error(err.stack);
      }
    });
    process.on('uncaughtException', function(error) {
      var err;
      try {
        child.kill();
      } catch (_error) {
        err = _error;
        console.error(err.stack);
      }
      throw error;
    });
    debug('start %s on port %s', name, port);
    return waitFor(child, port, timeout, function(error) {
      debug('started %s', name, error);
      if (error != null) {
        return cb(error);
      }
      return cb(null, child);
    });
  });
};

module.exports = {
  spawnServer: spawnServer
};
