_ = require 'underscore'
EventEmitter = require('events').EventEmitter

X = require './X'
Log = require './Log'
mouse = require '../common/Mouse'
Window = require './Window'

class Screen extends EventEmitter

	# Socket is set only for clients
	constructor: (@socket) ->
		@windows = {}
		@size =
			width: X.screen.pixel_width
			height: X.screen.pixel_height
		@mouse = mouse

		@mouse.on 'moved', => @HasReachedEdge @mouse.pos

	NewWindow: (blob) ->
		win = new Window blob

		win.on 'moved', => @HasReachedEdge win
		@AddWindow win

	AddWindow: (win) ->
		@windows[win.id] win

	DelWindow: (win) ->
		@windows = _(@windows).reject (item) -> item.id is win.id

	HasReachedEdge: (pos) ->
		if pos.x <= 0
			@emit 'switchLeft', pos
		else if pos.y <= 0
			@emit 'switchTop', pos
		else if pos.x >= @size.width - 1
			@emit 'switchRight', pos
		else if pos.y >= @size.height - 1
			@emit 'switchBottom', pos

	IsFullScreen: (win) ->
		if not win.x and win.width is @size.width and win.height > @size.height - 100
			return true
		return false

module.exports = Screen
