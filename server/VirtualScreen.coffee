_ = require 'underscore'

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

			@X.InitEventTree @X.root

		@X.on 'mousePos', (pos) =>
			@cursorPos = pos

			if (!@switchedOutput and @cursorPos.y <= 0) or (@switchedOutput and @cursorPos.y >= @screens[1].height - 1)
				@_SwitchOutput()

			if @switchedOutput
				@socket.emit 'mousePos', @cursorPos

		@X.on 'buttonDown', (i) =>
			if @switchedOutput
				@socket.emit 'buttonDown', i

		@X.on 'buttonUp', (i) =>
			if @switchedOutput
				@socket.emit 'buttonUp', i

		@X.on 'window', (win) =>
			# if @switchedOutput
			@socket.emit 'window', win

		@X.on 'switchOutput', =>
			@_SwitchOutput()

	_SwitchOutput: ->
		console.log 'Switch !', @switchedOutput

		@switchedOutput = !@switchedOutput
		if @switchedOutput
			@cursorPos =
				x: @cursorPos.x
				y: @screens[1].height - 2

			@X.CreateCaptureWindow()
			# @X.Grab()
			@X.MovePointer @cursorPos
		else
			# @X.Ungrab()
			@X.DestroyCaptureWindow()

			@cursorPos =
				x: @cursorPos.x
				y: 4

			@X.MovePointer @cursorPos

	AddScreen: (@socket) ->
		console.log 'AddScreen'
		@socket.once 'screenInfos', (infos) =>
			@screens.push infos

			# @socket.emit 'initialCursorPos', @cursorPos

			Log.Log 'New screen added: ', infos

			# @X.StartPointerQuery()

		@socket.emit 'askScreenInfos'

	Destroy: ->
		# @mouseRead.Close()


module.exports = VirtualScreen
