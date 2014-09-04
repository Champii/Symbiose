EventEmitter = require('events').EventEmitter

X = require './X'
Log = require './Log'
mouse = require '../common/Mouse'
Window = require './Window'

class DistantScreen extends EventEmitter

	constructor: (infos, @socket) ->
		@windows = []
		@size =
			width: infos.width
			height: infos.height
		@name = infos.name
		@screenPosition = infos.position
		@pos =
			x: 0
			y: 0

		@socket.emit 'clientPosition', @screenPosition

	MovePointer: (pos) ->
		@pos = pos

		@_ContentPointer()

		@socket.emit 'mousePos', @pos

	MovePointerRelative: (delta) ->
		@pos.x = @pos.x + delta.x
		@pos.y = @pos.y + delta.y

		@_ContentPointer()

		@socket.emit 'mousePos', @pos
		@HasReachedEdge()

	_ContentPointer: ->
		if @pos.x < 0
			@pos.x = 0

		if @pos.x >= @size.width
			@pos.x = @size.width

		if @pos.y < 0
			@pos.y = 0

		if @pos.y >= @size.height
			@pos.y = @size.height

	HasReachedEdge: ->
		if @pos.x <= 0 and @screenPosition is 'Right'
			@emit 'switch'

		else if @pos.y <= 0 and @screenPosition is 'Bottom'
			@emit 'switch'

		else if @pos.x >= @size.width and @screenPosition is 'Left'
			@emit 'switch'

		else if @pos.y >= @size.height and @screenPosition is 'Top'
			@emit 'switch'

	AddWindow: (win) ->
		@windows.push win

	DelWindow: (win) ->
		@windows = _(@windows).reject (item) -> item.id is win.id

module.exports = DistantScreen
