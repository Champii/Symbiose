x11 = require 'x11'
io = require('socket.io-client')

MouseWriter = require '../../common/compiled/MouseWriter'
Log = require '../../common/compiled/Log'

Config = require '../../gui/js/compiled/util/config'

config = new Config

class Client

	constructor: ->

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

	Stop: ->
		@socket = null

Log.SetLevel 2

module.exports = exports = Client
