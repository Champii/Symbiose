_ = require 'underscore'
EventEmitter = require('events').EventEmitter

Log = require './Log'
Window = require './Window'

class Screen extends EventEmitter

  constructor: ->
    @windows = {}

  NewWindow: (blob) ->
    win = new Window blob

    @AddWindow win
    win

  AddWindow: (win) ->
    if @HasWindow win
      return

    @windows[win.id] = win

  DelWindow: (win) ->
    @windows = _(@windows).reject (item) ->
      if item?
        item.wid is win.wid
      else
        false

  GetWindow: (wid) ->
    _(@windows).find((item) => item? and item.wid is wid)

  HasWindow: (win) ->
    @GetWindow(win.wid)?

  HasReachedEdge: (obj) ->

    if obj.x <= 1
      return 'Left'
      # @emit 'switchLeft', obj
    else if obj.y <= 1
      return 'Top'
      # @emit 'switchTop', obj
    else if obj.x >= @size.width - 2
      return 'Right'
      # @emit 'switchRight', obj
    else if obj.y >= @size.height - 2
      return 'Bottom'
      # @emit 'switchBottom', obj
    return

  IsFullScreen: (win) ->
    if not win.x and win.width is @size.width and win.height > @size.height - 100
      return true
    return false

module.exports = Screen
