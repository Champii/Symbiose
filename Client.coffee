x11 = require 'x11'
io = require('socket.io-client')

Log = require './Log'

class Client

	constructor: (host, port) ->

		x11.createClient (err, display) =>
		  return Log.Error err if err?

		  @screen =
		  	width: display.screen[0].pixel_width
		  	height: display.screen[0].pixel_height

			@socket = io host + ':' + port

			@socket.on 'askScreenInfos', =>
				@socket.emit 'screenInfos', @screen

			@socket.on 'mouseAction', (infos) => Log.Log infos


new Client 'http://localhost', 4242
