io = require('socket.io')(4242)

bus = require '../common/Bus'

VirtualScreen = require './VirtualScreen'

class Server

	constructor: ->
		@socket = null

		@virtScreen = new VirtualScreen

		io.sockets.on 'connection', (socket) =>
			@socket = socket


			@virtScreen.AddScreen @socket

			bus.on 'mousePos', (pos) =>
				@Send 'mousePos', pos

	Send: (action, message) ->
		@socket.emit action, message

new Server
