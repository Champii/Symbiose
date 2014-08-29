x11 = require 'x11'
io = require('socket.io-client')

Log = require '../../common/compiled/Log'
MouseWriter = require '../../common/compiled/MouseWriter'

Config = require '../../gui/js/compiled/util/config'

config = new Config

class Client

	constructor: ->
		Log.SetLevel 3

		x11.createClient (err, display) =>
		  return Log.Error err if err?

		  @screen =
		  	width: display.screen[0].pixel_width
		  	height: display.screen[0].pixel_height

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

	Stop: ->
		@socket = null


module.exports = exports = Client
