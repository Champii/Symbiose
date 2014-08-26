x11 = require 'x11'
io = require('socket.io-client')

MouseWriter = require './MouseWriter'
Log = require './Log'

class Client

	constructor: (host, port) ->

		x11.createClient (err, display) =>
		  return Log.Error err if err?

		  @screen =
		  	width: display.screen[0].pixel_width
		  	height: display.screen[0].pixel_height

		  Log.Warning @screen

			@socket = io 'http://' + host + ':' + port

			@socket.on 'askScreenInfos', =>
				@socket.emit 'screenInfos', @screen

			@mouseWrite = new MouseWriter

			@socket.on 'initialCursorPos', (pos) =>
				Log.Log 'initial pos', pos
				@mouseWrite.MoveTo pos

			@socket.on 'mousePos', (pos) =>
				Log.Log 'mouse pos', pos
				@mouseWrite.MoveTo pos

host = 'localhost'
port = 4242

if process.argv[2]?
	host = process.argv[2]
if process.argv[3]?
	port = process.argv[3]

Log.Log 'Connection to', host, port

Log.SetLevel 2

new Client host, port
