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

# Based on Mocha's Spec reporter.
#
# Adds ability to ensure we
# capture failures as they happen,
# even if it's in a before hook.

Base = require('mocha').reporters.Base
cursor = Base.cursor
color = Base.color

{getBrowser} = require '../index'
{takeScreenshotOnFailure} = require '../test_setup/screenshot'

module.exports = (screenshotDirectory) ->
  Spec = (runner) ->
    Base.call this, runner

    self = this
    stats = @stats
    indents = 0
    n = 0

    indent = ->
      Array(indents).join "  "

    runner.on "start", ->
      console.log()

    runner.on "suite", (suite) ->
      ++indents
      console.log color("suite", "%s%s"), indent(), suite.title

    runner.on "suite end", (suite) ->
      --indents
      console.log()  if 1 is indents

    runner.on "pending", (test) ->
      fmt = indent() + color("pending", "  - %s")
      console.log fmt, test.title

    runner.on "pass", (test) ->
      if "fast" is test.speed
        fmt = indent() + color("checkmark", "  " + Base.symbols.ok) + color("pass", " %s ")
        cursor.CR()
        console.log fmt, test.title
      else
        fmt = indent() + color("checkmark", "  " + Base.symbols.ok) + color("pass", " %s ") + color(test.speed, "(%dms)")
        cursor.CR()
        console.log fmt, test.title, test.duration

    runner.on "fail", (test, err) ->
      browser = getBrowser()
      takeScreenshotOnFailure(screenshotDirectory, test, browser)

      cursor.CR()
      console.log indent() + color("fail", "  %d) %s"), ++n, test.title

    runner.on "end", self.epilogue.bind(self)

  Spec.prototype.__proto__ = Base.prototype

  return Spec

