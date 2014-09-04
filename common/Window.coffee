EventEmitter = require('events').EventEmitter

X = require './X'
Log = require './Log'

validAttrs =
	wid: 0
	x: 0
	y: 0
	width: 100
	height: 100
	borderWidth: 1
	depth: 0
	type: 1
	visuals: 0
	attributes:
		eventMask: X.defaultEventMask
	visible: false

nextId = 0

class Window extends EventEmitter

	constructor: (attrs) ->
		@id = nextId++
		@Deserialize attrs

		if not @wid
			res = X.CreateWindow @
			@wid = res[0]
			@_cgid = res[1]

			if @visible
				@Show()
		else
			@GetWindowAttributes()

		@Init()

	Init: ->
		eventsHandlers =
		 ConfigureNotify: @HandleConfigure

		X.on 'event', (ev) =>
			if ev.wid is @wid
				eventsHandlers[ev.name]() if eventsHandlers[ev.name]?

	Deserialize: (attrs) ->
		for k, v of attrs when validAttrs[k]?
			@[k] = v

		for k, v of validAttrs
			if not @[k]?
				@[k] = v

	GetWindowAttributes: ->
		X.X.GetWindowAttributes @wid, (err, attrs) =>
			return Log.Error err if err?

			@Deserialize attrs

	Show: ->
		X.MapWindow @wid

	Hide: ->
		X.UnmapWindow @wid

	HandleConfigure: (ev) ->
		if ev.x isnt @x or ev.y isnt @y
			@x = ev.x
			@y = ev.y
			@emit 'moved'

		if ev.width isnt @width or ev.height isnt @height
			@width = ev.width
			@height = ev.height
			@emit 'resized'

	SendTo: (socket) ->
		X.GetWindowImage @wid, (err, image) =>
			return Log.Error err if err?

			socket.emit 'window'

module.exports = Window
