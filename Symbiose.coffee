exec = require('child_process').exec

Server = require './server/Server'
Client = require './client/Client'

class Symbiose

  constructor: ->

  Run: ->
    exec '../nodewebkit/nw .'

  RunServerCli: ->
    @server = new Server

  RunClientCli: ->
    @client = new Client

app = new Symbiose

if process.argv[2] is '-q' and process.argv[3] is '-s'
  app.RunServerCli()
else if process.argv[2] is '-q' and process.argv[3] is '-c'
  app.RunClientCli()
else
  app.Run()
