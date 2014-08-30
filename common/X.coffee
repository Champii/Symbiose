x11 = require 'x11'
EventEmitter = require('events').EventEmitter

Log = require './Log'

Exposure = x11.eventMask.Exposure
PointerMotion = x11.eventMask.PointerMotion
ButtonPress = x11.eventMask.ButtonPress
ButtonRelease = x11.eventMask.ButtonRelease
StructureNotify = x11.eventMask.StructureNotify

class X extends EventEmitter

	constructor: (done) ->
		@grabed = false

		x11.createClient (err, display) =>
			return Log.Error err if err?

			@display = display

			@X = @display.client
			@root = @display.screen[0].root

			done()

	InitEventTree: (root) ->
		@X.QueryTree root, (err, tree) =>
			return Log.Error err if err?

			tree.children.forEach (wid) =>
				@X.GetWindowAttributes wid, (err, attrs) =>
					return Log.Error err if err?

					@X.ChangeWindowAttributes wid,
						eventMask: Exposure|StructureNotify

					@InitEventTree wid

	StartPointerQuery: ->
		console.log @X
		@pointerTimer = setInterval =>
			@X.QueryPointer @root, (err, fields) =>
				return Log.Error err if err?
				# console.log 'HOST mouse: ', {x: fields.rootX, y: fields.rootY}
				@emit 'mousePos', {x: fields.rootX, y: fields.rootY}
		, 10

	StopPointerQuery: ->
		clearInterval @pointerTimer

	CreateBlankCursor: ->
		if not @cursorId?
			cursorSourceId = @X.AllocID()

			@X.CreatePixmap cursorSourceId,
											@captureWid,
											1,
											1,
											1

			gc = @X.AllocID()
			@X.CreateGC gc, cursorSourceId

			@X.CopyArea @root,
									cursorSourceId,
									gc,
									0,
									0,
									0,
									0,
									1,
									1

			color =
				R: 0
				G: 0
				B: 0

			@cursorId = @X.AllocID()

			@X.CreateCursor @cursorId,
											cursorSourceId,
											0,
											color,
											color,
											0,
											0

		return @cursorId

	CreateCaptureWindow: ->
		@captureWid = @X.AllocID()
		@X.CreateWindow @captureWid,
										@root,
										0,
										0,
										@display.screen[0].pixel_width,
										@display.screen[0].pixel_height,
										0,
										0,
										2,
										0,
											eventMask: PointerMotion|ButtonPress|ButtonRelease

		@X.ChangeWindowAttributes @captureWid,
			cursor: @CreateBlankCursor()

		@X.MapWindow @captureWid

		@X.on 'event', (ev) =>
			if ev.wid is @captureWid
				if ev.name is 'MotionNotify'
					@emit 'mousePos', {x: ev.x, y: ev.y}
				if ev.name is 'ButtonPress'
					console.log 'buttondown', ev.keycode
					@emit 'buttonDown', ev.keycode
				if ev.name is 'ButtonRelease'
					console.log 'buttonup', ev.keycode
					@emit 'buttonUp', ev.keycode

		@X.on 'error', (e) ->
			Log.Error e

	DestroyCaptureWindow: ->
		@X.removeAllListeners 'event'
		@X.DestroyWindow @captureWid
		@captureWid = null

	MovePointer: (pos) ->
		target = @root
		if @grabed
			target = @captureWid

		@X.WarpPointer 	null,
										target,
										0,
										0,
										0,
										pos.x,
										pos.y

	Grab: ->
		@X.GrabPointer 	@captureWid,
										false,
										{eventMask: PointerMotion|ButtonPress},
										undefined,
										undefined,
										@captureWid,
										(err, data) -> console.log 'Grab', err, data
		@grabed = true

	Ungrab: ->
		@X.UngrabPointer()
		@grabed = false

module.exports = X
