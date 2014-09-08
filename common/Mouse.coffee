exec = require('child_process').exec
EventEmitter = require('events').EventEmitter

X = require '../common/X'
Log = require '../common/Log'

class Mouse extends EventEmitter

  constructor: ->
    @pos =
      x: 0
      y: 0

    X.on 'event', (ev) =>
      if ev.name is 'MotionNotify'
        @pos =
          x: ev.rootx
          y: ev.rooty

        @emit 'moved'

        @HasReachedEdge()

      if ev.name is 'ButtonPress'
        @emit 'buttonDown', ev.keycode

      if ev.name is 'ButtonRelease'
        @emit 'buttonUp', ev.keycode

  MovePointer: (pos) ->
    @pos = pos
    X.MovePointer @pos

  MovePointerRelative: (delta) ->
    @pos =
      x: @pos.x + delta.x
      y: @pos.y + delta.y
    X.MovePointer @pos

  HasReachedEdge: ->
    if @pos.x <= 1
      @emit 'switchLeft', @pos
    else if @pos.y <= 1
      @emit 'switchTop', @pos
    else if @pos.x >= X.screen.pixel_width - 1
      @emit 'switchRight', @pos
    else if @pos.y >= X.screen.pixel_height - 1
      @emit 'switchBottom', @pos

  # TEMPORARY, will use XTest to simulate click
  _Xte: (order, args) ->
    exec "xte -x :0.0 '" + order + " " + args + "'"

  ButtonDown: (button) ->
    @_Xte 'mousedown', button

  ButtonUp: (button) ->
    @_Xte 'mouseup', button

module.exports = new Mouse
