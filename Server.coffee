io = require('socket.io')(4242)

bus = require './Bus'

VirtualScreen = require './VirtualScreen'

class Server

	constructor: ->
		@socket = null

		@virtScreen = new VirtualScreen

		io.sockets.on 'connection', (socket) =>
			@socket = socket

			@virtScreen.AddScreen @socket

			bus.on 'mouseAction', (infos) => @Send infos

	Send: (mouseInfos) ->
		# if @socket?
			@socket.emit 'mouseAction', mouseInfos

new Server
