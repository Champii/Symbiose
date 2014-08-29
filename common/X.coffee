x11 = require 'x11'
EventEmitter = require('events').EventEmitter

Log = require './Log'

# Exposure = x11.eventMask.Exposure
PointerMotion = x11.eventMask.PointerMotion
ButtonPress = x11.eventMask.ButtonPress

class X extends EventEmitter

	constructor: (done) ->
		@grabed = false

		x11.createClient (err, display) =>
			return Log.Error err if err?

			@display = display

			@X = @display.client
			@root = @display.screen[0].root

			done()

	StartPointerQuery: ->
	  @pointerTimer = setInterval =>
	    @X.QueryPointer @root, (err, fields) =>
	    	# console.log 'HOST mouse: ', {x: fields.rootX, y: fields.rootY}
	    	@emit 'mousePos', {x: fields.rootX, y: fields.rootY}
	  , 50

	StopPointerQuery: ->
		clearInterval @pointerTimer

	CreateCaptureWindow: (screenSize) ->
		@captureWid = @X.AllocID()
		@X.CreateWindow @captureWid,
										@root,
										@display.screen[0].pixel_width - 1,
										@display.screen[0].pixel_height - 1,
										screenSize.width,
										screenSize.height,
										0,
										0,
										1,
										0,
										{eventMask: PointerMotion|ButtonPress}

		@X.MapWindow @captureWid
		gc = @X.AllocID()
		@X.CreateGC gc, @captureWid

		@X.on 'event', (ev) =>
			if ev.name is 'MotionNotify' and ev.wid is @captureWid
				console.log 'Client mouse !', ev
				@emit 'mousePos', {x: ev.x, y: ev.y}

		@X.on 'error', (e) ->
		  Log.error e

	DestroyCaptureWindow: ->

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
