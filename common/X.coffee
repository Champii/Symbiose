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

class X extends EventEmitter

	constructor: ->
		@grabed = false
		@windowId = 0
		@windows = []

		@defaultEventMask = Exposure|PointerMotion|StructureNotify|SubstructureNotify

	Init: (done) ->
		x11.createClient (err, display) =>
			return Log.Error err if err?

			@display = display

			@X = @display.client
			@screen = @display.screen[0]
			@root = @screen.root

			@InitEventTree @root

			@X.on 'event', (ev) =>
				@emit 'event', ev if ev.wid?

				if ev.name is 'CreateNotify'
					@InitEventTree ev.parent

			@X.on 'error', (e) =>
				Log.Error e

			done()

	InitEventTree: (root) ->
		@X.QueryTree root, (err, tree) =>
			return Log.Error err if err?

			tree.children.forEach (wid) =>
				@X.ChangeWindowAttributes wid,
					eventMask: @defaultEventMask

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

	CreateWindow: (win) ->
		wid = @X.AllocID()
		@X.CreateWindow wid,
										@root,
										win.x,
										win.y,
										win.width,
										win.height,
										win.borderWidth, # border width
										win.depth, # depth
										win.type, # InputOutput
										win.visuals, # visuals
										win.attributes,
										(err) ->
											Log.Error 'CreateWindow', err

		gc = @X.AllocID()
		@X.CreateGC gc, wid, (err) => Log.Error 'CreateGC', err

		return [wid, gc]

	MapWindow: (wid) ->
		@X.MapWindow wid, (err) => Log.Error 'Map', err

	UnmapWindow: (wid) ->
		@X.UnmapWindow wid

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
											{eventMask: PointerMotion|ButtonPress|ButtonRelease},
										(err) => Log.Error 'CaptureWin', err if err?

		@X.ChangeWindowAttributes @captureWid,
			cursor: @CreateBlankCursor()

		@X.MapWindow @captureWid
		return @captureWid


	DestroyCaptureWindow: ->
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

	GetWindowImage: (win, done) ->
		@X.GetImage 2,
								win.wid,
								0,
								0,
								win.width,
								win.height,
								0xffffffff,
								done

	SendNewWindow: (ev) ->
		@emit 'switchOutput'

		console.log "SendNewWindow"
		winId = @windowId++

		if not winId
			@X.ChangeWindowAttributes ev.wid,
				backingStore: 2

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
												image: res
			, 2000

			@windows[winId] =
				timer: timer


	# CreateWindow: (win) ->
	# 	console.log 'CreateWindow'
	# 	@windows[win.id] = win

	# 	@windows[win.id].wid = @X.AllocID()


	# 	@X.CreateWindow @windows[win.id].wid,
	# 									@root,
	# 									0,
	# 									0,
	# 									win.width,
	# 									win.height,
	# 									0, # border width
	# 									24, # depth
	# 									1, # InputOutput
	# 									0, # visuals
	# 										{eventMask: @defaultEventMask},
	# 									(err) ->
	# 										Log.Error 'CreateWindow', err

	# 	@X.MapWindow @windows[win.id].wid

	# 	@windows[win.id].gc = @X.AllocID()
	# 	@X.CreateGC @windows[win.id].gc, @windows[win.id].wid

	FillWindow: (win, image) ->
		# console.log 'FillWindow', image

		@X.PutImage 2,
								win.wid,
								win._cgid,
								win.width,
								win.height,
								0,
								0,
								0, # left paded
								24, # depth
								image.data,
								(err, lol) -> console.log 'PutImage', err


module.exports = new X
