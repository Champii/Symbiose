x11 = require 'x11'

bus = require '../../common/compiled/Bus'
Log = require '../../common/compiled/Log'

MouseReader = require '../../common/compiled/MouseReader'
MouseWriter = require '../../common/compiled/MouseWriter'

class VirtualScreen

	constructor: ->

		@screens = []
		@cursorPos =
			x: 0
			y: 0
		@switchedInput = false

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
				@_UpdateCursor infos


				# Log.Log @cursorPos

			@mouseRead.on 'buttonDown', (infos) =>
				@_UpdateCursor infos
				bus.emit 'buttonDown', infos.button

			@mouseRead.on 'buttonUp', (infos) =>
				@_UpdateCursor infos
				bus.emit 'buttonUp', infos.button

	_UpdateCursor: (infos) ->
		@cursorPos.x += infos.xDelta
		@cursorPos.y -= infos.yDelta

		if @cursorPos.y < 0 and @socket?
			@_SwitchInput() if !@switchedInput

			@mouseWrite.MoveTo {x: 1000, y: 1000}
			@socket.emit 'mousePos',
				x: @cursorPos.x
				y: @cursorPos.y + @screens[1].height
		else
			@_SwitchInput() if @switchedInput
			if Math.abs(infos.xDelta) > 3 or Math.abs(infos.yDelta) > 3
				@mouseWrite.MoveTo @cursorPos

	_SwitchInput: ->
		@switchedInput = !@switchedInput
		# if @switchedInput
		# 	win.focus()


	AddScreen: (@socket) ->
	  @socket.once 'screenInfos', (infos) =>
		  @screens.push infos

		  @socket.emit 'initialCursorPos', @cursorPos

		  Log.Log 'New screen added: ', infos

	  @socket.emit 'askScreenInfos'

	Destroy: ->
		@mouseRead.Close()


module.exports = VirtualScreen
