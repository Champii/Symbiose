x11 = require 'x11'

bus = require './Bus'
Log = require './Log'

MouseReader = require './MouseReader'
MouseWriter = require './MouseWriter'

class VirtualScreen

	constructor: ->

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
			if infos.xOverflow or infos.yOverflow
				@mouseWrite.MoveTo @cursorPos

			@cursorPos.x += infos.xDelta
			@cursorPos.y -= infos.yDelta

			Log.Log @cursorPos
			bus.emit 'mouseAction', infos

		@mouseRead.on 'button', (infos) =>
			bus.emit 'mouseAction', infos

	AddScreen: (@socket) ->
	  @socket.once 'screenInfos', (infos) =>
		  @screens.push = infos
		  Log.Log 'New screen added: ', infos

	  @socket.emit 'askScreenInfos'

module.exports = VirtualScreen
