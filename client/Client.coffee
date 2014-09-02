io = require('socket.io-client')

Log = require '../../common/compiled/Log'
MouseWriter = require '../../common/compiled/MouseWriter'

Config = require '../../gui/js/compiled/util/config'

X = require '../../common/compiled/X'

config = new Config

class Client

	constructor: ->
		Log.SetLevel 2

		@X = new X =>
			console.log 'lol'
			@screen =
		  	width: @X.display.screen[0].pixel_width
		  	height: @X.display.screen[0].pixel_height

		  Log.Warning @screen

			@socket = io 'http://' + config.host + ':' + config.port

			@socket.on 'askScreenInfos', =>
				@socket.emit 'screenInfos', @screen

			@mouseWrite = new MouseWriter

			@socket.on 'initialCursorPos', (pos) =>
				Log.Log 'initial pos', pos
				@mouseWrite.MoveTo pos

			@socket.on 'mousePos', (pos) =>
				Log.Log 'mouse pos', pos
				@mouseWrite.MoveTo pos

			@socket.on 'buttonDown', (i) =>
				@mouseWrite.ButtonDown i

			@socket.on 'buttonUp', (i) =>
				@mouseWrite.ButtonUp i

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
