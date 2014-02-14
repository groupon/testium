StaticServer = require('node-static').Server
http = require('http')

echo = (request, response) ->
  data = {
    ip: request.connection.remoteAddress
    method: request.method
    url: request.url
    body: ""
    headers: request.headers
  }

  request.on 'data', (buffer) ->
    data.body += buffer.toString()

  request.on 'end', ->
    body = JSON.stringify(data, null, 2)
    response.end(body)

error = (response) ->
  response.statusCode = 500
  response.write '500 SERVER ERROR'
  response.end()

crash = (response) ->
  response.statusCode = 500
  response.socket.destroy()

createServer = ->
  file = new StaticServer("#{__dirname}/public")
  http.createServer (request, response) ->
    if request.url == '/echo'
      return echo(request, response)

    if request.url == '/error'
      return error(response)

    if request.url == '/crash'
      return crash(response)

    if request.url == '/blackhole'
      return

    listener = request.addListener 'end', ->
      file.serve(request, response)
    listener.resume()

module.exports =
  listen: (port, callback) ->
    @server = createServer()
    @server.listen port, callback

  kill: (callback) ->
    @server.close callback
    @server = null

