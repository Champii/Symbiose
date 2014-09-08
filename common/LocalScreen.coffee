_ = require 'underscore'
EventEmitter = require('events').EventEmitter

X = require './X'
Log = require './Log'
mouse = require './Mouse'
Window = require './Window'
Screen = require './Screen'

class LocalScreen extends Screen

  constructor: ->
    super()

    @size =
      width: X.screen.pixel_width
      height: X.screen.pixel_height

    @mouse = mouse

  NewWindow: (blob) ->
    win = super blob

    win.on 'moved', => @HasReachedEdge win

  HasReachedEdge: (obj) ->
    edge = super obj

    @emit 'switch' + edge, obj if edge

    # FIXME: bottom bar dirty trick
    # if obj.y >= @size.height - 200 and obj.distant
    #   reached = true
    #   @emit 'switchBottom', obj

    # if obj.distant and edge
    #   @emit 'windowReturn', obj
    #   obj.Destroy()
    #   @DelWindow obj

module.exports = LocalScreen
