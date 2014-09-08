_ = require 'underscore'

X = require '../common/X'
Log = require '../common/Log'
Window = require '../common/Window'
VirtualDisplay = require '../common/VirtualDisplay'
LocalScreenServer = require './LocalScreenServer'
DistantScreenServer = require './DistantScreenServer'

class VirtualDisplayServer extends VirtualDisplay

  constructor: ->
    super()

    # switched is false or contain current client
    @switched = false

    @mainScreen = new LocalScreenServer

    @screenPlacement['Top'].expectedClient = 'client1' # Hard test for server

    @captureWin = 0

    center =
      x: @mainScreen.size.width / 2
      y: @mainScreen.size.height / 2

    @mouse.on 'moved', =>
      if @switched and @mouse.pos.x isnt center.x and @mouse.pos.y isnt center.y
        pos =
          x: @mouse.pos.x - center.x
          y: @mouse.pos.y - center.y

        @switched.MovePointerRelative pos

        @mouse.MovePointer center

    @mouse.on 'buttonDown', (k) =>
      if @switched
        @switched.socket.emit 'buttonDown', k

    @mouse.on 'buttonUp', (k) =>
      if @switched
        @switched.socket.emit 'buttonUp', k

    @keyboard.on 'keyDown', (k) =>
      if @switched
        @switched.socket.emit 'keyDown', k

    @keyboard.on 'keyUp', (k) =>
      if @switched
        @switched.socket.emit 'keyUp', k

    X.on 'event', (ev) =>
      if ev.name is 'ConfigureNotify'
        # Prevent capture window to be added to Screen's window collection
        if @captureWin and ev.wid is @captureWin
          return

        if @mainScreen.HasWindow ev
          return

        for k, v of @screenPlacement
          if v.client? and v.client.HasWindow ev
            return

        @mainScreen.NewWindow ev

  EnableSwitch: (placement) ->
    @mainScreen.on 'switch' + placement, (obj) =>

      if obj.wid? and @mainScreen.HasWindow obj # Is window ?
        # Don't trigger twice
        obj.Move
          x: 100
          y: 100

        @SwitchWindowTo obj, @screenPlacement[placement].client

      @_Switch placement

  _AfterSwitchPos: (placement, mouse) ->
    pos =
      x: @screenPlacement[placement].afterSwitchPos.x
      y: @screenPlacement[placement].afterSwitchPos.y

    pos.x = mouse.pos.x if pos.x is 'mouse'
    pos.y = mouse.pos.y if pos.y is 'mouse'

    pos.x = @screenPlacement[placement].client.size.width - 2 if pos.x is 'clientMax'
    pos.y = @screenPlacement[placement].client.size.height - 2 if pos.y is 'clientMax'

    pos.x = 2 if pos.x is 'clientMin'
    pos.y = 2 if pos.y is 'clientMin'

    pos

  _SwitchPointers: (switched, placement) ->
    if placement
      pos = @_AfterSwitchPos placement, @mouse

      @screenPlacement[placement].client.MovePointer pos

      @mouse.MovePointer
        x: @mainScreen.size.width / 2
        y: @mainScreen.size.height / 2
    else
      pos = @_AfterSwitchPos @screenPlacement[switched.placement].reverse, switched

      #FIXME
      _.defer =>
        @mouse.MovePointer pos

  _Switch: (placement) ->
    # console.log 'Switch', placement

    switchedSave = @switched

    if @switched and placement?
      # console.log 'Already Switched.'
      return

    if @switched or not placement?
      @switched = false
    else
      @switched = @screenPlacement[placement].client

    @_SwitchPointers switchedSave, placement

    if @switched
      @captureWin = X.CreateCaptureWindow()
      # X.Grab()
    else
      # X.Ungrab()
      X.DestroyCaptureWindow()
      @captureWin = 0

  SwitchWindowTo: (win, screen) ->
    # console.log 'Switch Win'
    # @mouse.ButtonUp 1
    pos = @_AfterSwitchPos screen.placement,
      pos:
        x: win.x
        y: win.y

    #test
    pos =
      x: 100
      y: 100

    screen.socket.emit 'newWindow', _(win.Serialize()).extend pos
    @mainScreen.DelWindow win
    screen.AddWindow win

  AddScreen: (socket) ->
    socket.once 'screenInfos', (infos) =>

      for k, v of @screenPlacement
        if v.expectedClient is infos.name
          infos.placement = k
          infos.placementReverse = @screenPlacement[k].reverse

          @screenPlacement[k].client = new DistantScreenServer infos, socket

          @screenPlacement[k].client.on 'switch', =>
            @_Switch()

          @screenPlacement[k].client.socket.on 'windowReturn', (win) =>
            win = @screenPlacement[k].client.DelWindow win
            @mainScreen.AddWindow win

          @EnableSwitch k

          Log.Log 'New screen added: ', infos
          return

    socket.emit 'askScreenInfos'

module.exports = VirtualDisplayServer
