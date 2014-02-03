assert = require 'assertive'
{ parseLogs, filterLogs } = require '../../../../lib/api/debug/console'

describe 'parseLogs', ->
  it 'maps log levels to browser log types', ->
    logs = [
      { level: 'SEVERE' }
    ]
    parsed = parseLogs logs
    log = parsed[0]

    assert.equal log.level, undefined
    assert.equal log.type, 'error'

describe 'filterLogs', ->
  it 'returns all logs if no type is given', ->
    logs = [
      { type: 'error', message: 'something broke' }
      { type: 'log', message: 'things are working' }
    ]

    {matched} = filterLogs logs
    assert.deepEqual logs, matched

  it 'filters logs based on type', ->
    errorItem = { type: 'error', message: 'something broke' }
    logItem = { type: 'log', message: 'things are working' }
    logs = [
      logItem
      errorItem
    ]

    { matched, rest } = filterLogs logs, 'error'
    assert.equal errorItem, matched[0]
    assert.equal 1, matched.length
    assert.equal logItem, rest[0]
    assert.equal 1, rest.length

