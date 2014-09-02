x11 = require 'x11'
EventEmitter = require('events').EventEmitter

Log = require './Log'

Exposure = x11.eventMask.Exposure
PointerMotion = x11.eventMask.PointerMotion
ButtonMotion = x11.eventMask.ButtonMotion
Button1Motion = x11.eventMask.Button1Motion
ButtonPress = x11.eventMask.ButtonPress
ButtonRelease = x11.eventMask.ButtonRelease
StructureNotify = x11.eventMask.StructureNotify
SubstructureNotify = x11.eventMask.SubstructureNotify

defaultEvents = Exposure|PointerMotion|StructureNotify|SubstructureNotify

class X extends EventEmitter

	constructor: (done) ->
		@grabed = false
		@windowId = 0
		@windows = []
		@dragging = false

		x11.createClient (err, display) =>
			return Log.Error err if err?

			@display = display

			@X = @display.client
			@screen = @display.screen[0]
			@root = @screen.root

			# console.log @X

			@X.on 'event', (ev) =>

				console.log ev if ev.name is 'ConfigureNotify'
				if ev.name is 'ConfigureNotify' and ev.y <= 0 and not @IsFullScreen ev
					console.log 'Configure : ', ev.x, ev.y
					@SendNewWindow ev

				if ev.name is 'CreateNotify'
					@InitEventTree ev.parent

				# if ev.name is 'DestroyNotify'
					# console.log ev
					# @InitEventTree ev.parent

				if ev.name is 'MotionNotify'
					# console.log ev.x, ev.y
					@emit 'mousePos', {x: ev.rootx, y: ev.rooty}


				if ev.name is 'ButtonPress'
					if not @dragging and ev.keycode is 1
						console.log 'Drag start'
						@dragging = true

					if ev.wid is @captureWid
						console.log 'buttondown', ev.keycode
						@emit 'buttonDown', ev.keycode

				if ev.name is 'ButtonRelease'
					if @dragging and ev.keycode is 1
						console.log 'Drag stop'
						@dragging = false

					if ev.wid is @captureWid
						console.log 'buttonup', ev.keycode
						@emit 'buttonUp', ev.keycode

			@X.on 'error', (e) ->
				Log.Error e

			done()

	IsFullScreen: (win) ->
		if not win.x and win.width is @screen.width and win.height > @screen.height - 50
			return true
		return false

	InitEventTree: (root) ->
		@X.QueryTree root, (err, tree) =>
			return Log.Error err if err?

			tree.children.forEach (wid) =>
				@X.GetWindowAttributes wid, (err, attrs) =>
					return Log.Error err if err?

					@X.ChangeWindowAttributes wid,
						eventMask: defaultEvents

					@InitEventTree wid

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


			@X.PutImage 1,
									cursorSourceId,
									gc,
									1,
									1,
									0,
									0,
									0,
									1,
									0

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


	DestroyCaptureWindow: ->
		# @X.removeAllListeners 'event'
		@X.DestroyWindow @captureWid
		@captureWid = null

	MovePointer: (pos) ->
		target = @root
		# if @grabed
		# 	target = @captureWid

		@X.WarpPointer 	0,
										target,
										0,
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

	SendNewWindow: (ev) ->
		@emit 'switchOutput'

		console.log "SendNewWindow", ev
		winId = @windowId++

		if not winId
			timer = setInterval =>
				@X.GetImage 2,
										ev.wid,
										0,
										0,
										ev.width,
										ev.height,
										0xffffffff,
										(err, res) =>
											return Log.Error err if err?

											console.log 'GetImage', res

											@emit 'window',
												id: winId
												width: ev.width
												height: ev.height
												# image: res
			, 2000

			@windows[winId] =
				timer: timer

	CreateWindow: (win) ->
		console.log 'CreateWindow'
		@windows[win.id] = win

		@windows[win.id].wid = @X.AllocID()


		@X.CreateWindow @windows[win.id].wid,
										@root,
										0,
										0,
										win.width,
										win.height,
										0, # border width
										24, # depth
										1, # InputOutput
										0, # visuals
											eventMask: defaultEvents,
										(err) ->
											Log.Error 'CreateWindow', err



		@X.MapWindow @windows[win.id].wid

		@windows[win.id].gc = @X.AllocID()
		@X.CreateGC @windows[win.id].gc, @windows[win.id].wid

	FillWindow: (data) ->
		console.log 'FillWindow'
		if not @windows[data.id]?
			@CreateWindow data

		win = @windows[data.id]


		# console.log @windows
		# @X.PutImage 2,
		# 						win.wid,
		# 						win.gc,
		# 						win.width,
		# 						win.height,
		# 						0,
		# 						0,
		# 						0, # left paded
		# 						24, # depth
		# 						win.image.data,
		# 						(err, lol) -> console.log 'PutImage', err


module.exports = X
