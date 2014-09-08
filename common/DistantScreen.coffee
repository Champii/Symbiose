_ = require 'underscore'
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
    @placement = infos.placement
    @pos =
      x: 0
      y: 0

    @socket.emit 'clientPosition', @placement

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
    if @pos.x <= 1 and @placement is 'Right'
      @emit 'switch'

    else if @pos.y <= 1 and @placement is 'Bottom'
      @emit 'switch'

    else if @pos.x >= @size.width - 2 and @placement is 'Left'
      @emit 'switch'

    else if @pos.y >= @size.height - 2 and @placement is 'Top'
      @emit 'switch'

  GetWindow: (wid) ->
    _(@windows).find((item) => item? and item.wid is wid)

  HasWindow: (win) ->
    if _(@windows).find((item) => item? and item.wid is win.wid)?
      true
    else
      false

  AddWindow: (win) ->
    if @HasWindow win
      return

    @windows.push win

    X.composite.RedirectSubwindows win.wid, X.composite.Redirect.Automatic, (err) => Log.Error 'Composite: RedirectWindow', err if err?

    win.GetOffPixmap()
    win.ActivateDamage @socket

    win.SendTo @socket

    # win.Hide()

    # win.timer = setInterval =>
    #   win.SendTo @socket
    # , 500

  DelWindow: (win) ->
    clearInterval win.timer
    @windows = _(@windows).reject (item) -> item.id is win.id

module.exports = DistantScreen
