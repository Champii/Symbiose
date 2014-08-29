bus = require '../../common/compiled/Bus'
Log = require '../../common/compiled/Log'

X = require '../../common/compiled/X'

class VirtualScreen

	constructor: ->

		@screens = []
		@cursorPos =
			x: 0
			y: 0
		@switchedOutput = false

		@X = new X =>
			@screens[0] =
				width: @X.display.screen[0].pixel_width
				height: @X.display.screen[0].pixel_height

			Log.Log 'Host screen', @screens[0]

		@X.on 'mousePos', (pos) =>
			console.log 'lol', pos
			@cursorPos = pos

			if (!@switchedOutput and @cursorPos.y <= 0) or (@switchedOutput and @cursorPos.y >= @screens[1].height - 1)
				@_SwitchOutput()

			if @switchedOutput
				@socket.emit 'mousePos', @cursorPos

	_SwitchOutput: ->
		console.log 'Switch !', @screens

		@switchedOutput = !@switchedOutput
		if @switchedOutput
			@cursorPos =
				x: @cursorPos.x
				y: @screens[0].height - 1

			@X.StopPointerQuery()
			@X.CreateCaptureWindow @screens[1]
			@X.MovePointer @cursorPos
			@X.Grab()
		else
			@X.Ungrab()
			@cursorPos =
				x: @cursorPos.x
				y: 0

			@X.MovePointer @cursorPos
			@X.DestroyCaptureWindow()
			@X.StartPointerQuery()

	AddScreen: (@socket) ->
	  @socket.once 'screenInfos', (infos) =>
		  @screens.push infos

		  # @socket.emit 'initialCursorPos', @cursorPos

		  Log.Log 'New screen added: ', infos

		  @X.StartPointerQuery()

	  @socket.emit 'askScreenInfos'

	Destroy: ->
		# @mouseRead.Close()


module.exports = VirtualScreen
