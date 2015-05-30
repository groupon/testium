http = require 'http'

setTimeout ->
  throw 'error!'
, 2000

http.createServer((req, res) ->
  res.writeHead 200, {'Content-Type': 'text/plain'}
  res.end 'Hello World\n'
).listen(1337)
