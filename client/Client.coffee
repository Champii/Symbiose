io = require('socket.io-client')

X = require '../common/X'
Log = require '../common/Log'
mouse = require '../common/Mouse'
Config = require '../gui/js/util/config'
VirtualDisplay = require '../common/VirtualDisplay'

config = new Config

class Client

	constructor: ->
		Log.SetLevel 3
		@mouse = mouse

		# @screen =
		# 	width: @X.screen.pixel_width
		# 	height: @X.screen.pixel_height
		# 	name: 'client1'

		# Log.Warning @screen

		X.Init =>
			@socket = io 'http://' + config.host + ':' + config.port

			@virtDisplay = new VirtualDisplay @socket

			@socket.on 'askScreenInfos', =>
				@socket.emit 'screenInfos',
					width: @virtDisplay.mainScreen.size.width
					height: @virtDisplay.mainScreen.size.height
					name: 'client1'

			@socket.on 'mousePos', (pos) =>
				@mouse.MovePointer pos

			@socket.on 'buttonDown', (i) =>
				@mouse.ButtonDown i

			@socket.on 'buttonUp', (i) =>
				@mouse.ButtonUp i

			@socket.on 'window', (win) =>
				console.log 'Window info !'
				@X.FillWindow win

			@socket.on 'disconnect', ->
				Log.Warning 'Disconnected'

			@socket.on 'error', (err) ->
				Log.Error err

	Stop: ->
		@socket = null


module.exports = exports = Client
