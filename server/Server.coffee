bus = require '../common/Bus'

X = require '../common/X'
VirtualDisplay = require '../common/VirtualDisplay'

Config = require '../gui/js/util/config'

config = new Config

class Server

	constructor: ->
		io = require('socket.io')(config.port)

		@socket = null

		X.Init =>
			@virtDisplay = new VirtualDisplay

			io.sockets.on 'connection', (socket) =>
				@socket = socket

				@virtDisplay.AddScreen @socket

	Stop: ->
		@virtDisplay.Destroy()
		@socket = null
		@virtDisplay = null

module.exports = exports = Server
