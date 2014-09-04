_ = require 'underscore'

X = require './X'
mouse = require './Mouse'
Log = require './Log'
Screen = require './Screen'
Window = require './Window'
DistantScreen = require './DistantScreen'


class VirtualDisplay

	# @socket is null if server
	constructor: (@socket) ->
		# switched is false or contain current client
		@switched = false
		@mouse = mouse

		@mainScreen = new Screen

		@screenPositions =
			Top:
				reverse: 'Bottom'
				expectedClient: 'client1' # Hard test for server
				afterSwitchPos:
					x: 'mouse'
					y: 'clientMax'
			Bottom:
				reverse: 'Top'
				afterSwitchPos:
					x: 'mouse'
					y: 'clientMin'
			Left:
				reverse: 'Right'
				afterSwitchPos:
					x: 'clientMin'
					y: 'mouse'
			Right:
				reverse: 'Left'
				afterSwitchPos:
					x: 'clientMax'
					y: 'mouse'

		# server
		if not @socket?

			@captureWin = 0

			center =
				x: @mainScreen.size.width / 2
				y: @mainScreen.size.height / 2

			@mouse.on 'moved', =>
				if @switched and @mouse.pos.x isnt center.x and @mouse.pos.y isnt center.y
					pos =
						x: @mouse.pos.x - center.x
						y: @mouse.pos.y - center.y

					@switched.MovePointerRelative pos

					@mouse.MovePointer center
		# client
		else
			@socket.on 'window', (data) =>
				console.log 'Window info !'
				win = _(@mainScreen.windows).find((item) => item? and item.hostId is data.hostId)
				if not win
					win = @mainScreen.NewWindow data
				else
					win.FillWindow data.image

			@socket.on 'clientPosition', (position) =>
				@clientPosition = position
				@serverPosition = @screenPositions[position].reverse

		X.on 'event', (ev) =>
			if ev.name is 'ConfigureNotify'
				# Prevent capture window to be added to Screen's window collection
				if @captureWin and ev.wid is @captureWin
					return

				for k, v of @windows
					if v? and _(v.windows).find((item) => item? and item.wid is ev.wid)?
						return

				win = _(@mainScreen.windows).find((item) => item? and item.wid is ev.wid)
				if not win?
					@mainScreen.NewWindow ev

	EnableSwitch: (position) ->
		@mainScreen.on 'switch' + position, (obj) =>

			if obj.wid?
				@SwitchWindowTo obj, @screenPositions[position].client

			@_Switch position


	_SwitchPointers: (switched, position) ->
		if position
			pos =
				x: @screenPositions[position].afterSwitchPos.x
				y: @screenPositions[position].afterSwitchPos.y

			pos.x = @mouse.pos.x if pos.x is 'mouse'
			pos.y = @mouse.pos.y if pos.y is 'mouse'

			pos.x = @screenPositions[position].client.size.width - 2 if pos.x is 'clientMax'
			pos.y = @screenPositions[position].client.size.height - 2 if pos.y is 'clientMax'

			pos.x = 2 if pos.x is 'clientMin'
			pos.y = 2 if pos.y is 'clientMin'

			@screenPositions[position].client.MovePointer pos

			@mouse.MovePointer
				x: @mainScreen.size.width / 2
				y: @mainScreen.size.height / 2
		else
			pos =
				x: @screenPositions[@screenPositions[switched.screenPosition].reverse].afterSwitchPos.x
				y: @screenPositions[@screenPositions[switched.screenPosition].reverse].afterSwitchPos.y

			pos.x = switched.pos.x if pos.x is 'mouse'
			pos.y = switched.pos.y if pos.y is 'mouse'

			pos.x = @mainScreen.size.width - 2 if pos.x is 'clientMax'
			pos.y = @mainScreen.size.height - 2 if pos.y is 'clientMax'

			pos.x = 2 if pos.x is 'clientMin'
			pos.y = 2 if pos.y is 'clientMin'

			#FIXME
			_.defer =>
				@mouse.MovePointer pos

	_Switch: (position) ->
		console.log 'Switch', position

		switchedSave = @switched

		if @switched or not position?
			@switched = false
		else
			@switched = @screenPositions[position].client

		@_SwitchPointers switchedSave, position

		if @switched
			@captureWin = X.CreateCaptureWindow()
			# X.Grab()
		else
			# X.Ungrab()
			X.DestroyCaptureWindow()
			@captureWin = 0

	SwitchWindowTo: (win, screen) ->
		console.log 'Switch Win'
		win.SendTo screen.socket
		@mainScreen.DelWindow win
		screen.AddWindow win

	AddScreen: (socket) ->
		socket.once 'screenInfos', (infos) =>

			for k, v of @screenPositions
				if v.expectedClient is infos.name
					infos.position = k

					@screenPositions[k].client = new DistantScreen infos, socket

					@screenPositions[k].client.on 'switch', =>
						@_Switch()

					@EnableSwitch k

					Log.Log 'New screen added: ', infos
					return

		socket.emit 'askScreenInfos'

module.exports = VirtualDisplay
