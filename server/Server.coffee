bus = require '../../common/compiled/Bus'

VirtualScreen = require './VirtualScreen'

Config = require '../../gui/js/compiled/util/config'

config = new Config

class Server

	constructor: ->
		io = require('socket.io')(config.port)

		@socket = null

		@virtScreen = new VirtualScreen

		io.sockets.on 'connection', (socket) =>
			@socket = socket

			@virtScreen.AddScreen @socket

			bus.on 'mousePos', (pos) =>
				@Send 'mousePos', pos

			bus.on 'buttonDown', (button) =>
				@Send 'buttonDown', button

			bus.on 'buttonUp', (button) =>
				@Send 'buttonUp', button


	Send: (action, message) ->
		console.log 'Send', action, message
		@socket.emit action, message

	Stop: ->
		@virtScreen.Destroy()
		@socket = null
		@virtScreen = null

module.exports = exports = Server
