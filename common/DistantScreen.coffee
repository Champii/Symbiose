_ = require 'underscore'
EventEmitter = require('events').EventEmitter

X = require './X'
Log = require './Log'
Window = require './Window'
Screen = require './Screen'

class DistantScreen extends Screen

  constructor: (infos, @socket) ->
    super()

    @size =
      width: infos.width
      height: infos.height

    @name = infos.name

    @placement = infos.placement
    @placementReverse = infos.placementReverse

    @pos =
      x: 0
      y: 0

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
    edge = super @.pos

    @emit 'switch' if edge is @placementReverse

  AddWindow: (win) ->
    if @HasWindow win
      return

    super win

    X.composite.RedirectSubwindows win.wid, X.composite.Redirect.Automatic, (err) => Log.Error 'Composite: RedirectWindow', err if err?

    win.GetOffPixmap()
    win.ActivateDamage @socket

    win.SendTo @socket

    win.Hide()

  DelWindow: (win) ->
    win = @GetWindow win

    win.DesactivateDamage()

    X.composite.RedirectSubwindows win.wid, (err) => Log.Error 'Composite: UnredirectWindows', err if err?

    win.Show()

    super win

    win


module.exports = DistantScreen
