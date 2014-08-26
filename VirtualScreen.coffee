x11 = require 'x11'

bus = require './Bus'
Log = require './Log'

MouseReader = require './MouseReader'
MouseWriter = require './MouseWriter'

class VirtualScreen

	constructor: (@socket) ->

		@screens = []
		@cursorPos =
			x: 0
			y: 0

		x11.createClient (err, display) =>
		  return Log.Error err if err?

		  @screens[0] =
		  	width: display.screen[0].pixel_width
		  	height: display.screen[0].pixel_height

		  Log.Log 'Host screen', @screens[0]

			# Used to set original mouse position
			@mouseWrite = new MouseWriter
			@mouseWrite.MoveTo @cursorPos

			# Used to get mouse actions
			@mouseRead = new MouseReader

			@mouseRead.on 'moved', (infos) =>
				@cursorPos.x += infos.xDelta
				@cursorPos.y -= infos.yDelta

				if Math.abs(infos.xDelta) > 3 or Math.abs(infos.yDelta) > 3
					@mouseWrite.MoveTo @cursorPos

				if @cursorPos.y < 0
					@socket.emit 'mousePos',
						x: @cursorPos.x
						y: @cursorPos.y + @screens[1].height



				Log.Log @cursorPos

			@mouseRead.on 'button', (infos) =>
				bus.emit 'mouseButton', infos

	AddScreen: (@socket) ->
	  @socket.once 'screenInfos', (infos) =>
		  @screens.push infos

		  @socket.emit 'initialCursorPos', @cursorPos

		  Log.Log 'New screen added: ', infos

	  @socket.emit 'askScreenInfos'

module.exports = VirtualScreen
