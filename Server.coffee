io = require('socket.io')(4242)

bus = require './Bus'

VirtualScreen = require './VirtualScreen'

class Server

	constructor: ->
		@socket = null


		io.sockets.on 'connection', (socket) =>
			@socket = socket

			@virtScreen = new VirtualScreen @socket

			@virtScreen.AddScreen @socket

			bus.on 'mousePos', (pos) =>
				@Send 'mousePos', pos

	Send: (action, message) ->
		@socket.emit action, message

new Server
