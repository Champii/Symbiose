_ = require 'underscore'

X = require './X'
mouse = require './Mouse'
Log = require './Log'
Screen = require './Screen'
Window = require './Window'
DistantScreen = require './DistantScreen'


class VirtualDisplay

  # @socket is null if server
  constructor: (@socket) ->
    # switched is false or contain current client
    @switched = false
    @mouse = mouse

    @mainScreen = new Screen

    @screenPlacement =
      Top:
        reverse: 'Bottom'
        expectedClient: 'client1' # Hard test for server
        afterSwitchPos:
          x: 'mouse'
          y: 'clientMax'
      Bottom:
        reverse: 'Top'
        afterSwitchPos:
          x: 'mouse'
          y: 'clientMin'
      Left:
        reverse: 'Right'
        afterSwitchPos:
          x: 'clientMax'
          y: 'mouse'
      Right:
        reverse: 'Left'
        afterSwitchPos:
          x: 'clientMin'
          y: 'mouse'

    # server
    if not @socket?

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

    # client
    else
      # @mouse.on 'moved', =>
      #   win = _(@mainScreen.windows).find((item) => item? and item.hostId?)
      #   if win?
      #     win.Move @mouse.pos

      @socket.on 'newWindow', (data) =>
        win = _(@mainScreen.windows).find((item) => item? and item.hostId is data.hostId)
        if not win?
          console.log 'New window !', data
          # data.attributes =
          #   overrideRedirect: 1
          win = @mainScreen.NewWindow data

          # hack to make window well positioned and dragging
          # setTimeout =>
          #   console.log data
          #   @mouse.MovePointer
          #     x: 70
          #     y: 10
          #   setTimeout =>
          #     @mouse.ButtonDown 1
          #     setTimeout =>
          #       @mouse.MovePointer
          #         x: data.x / 2
          #         y: data.y / 2
          #     , 500
          #   , 500
          # , 500

      @socket.on 'windowContent', (data) =>
        console.log 'Window content'
        win = _(@mainScreen.windows).find((item) => item? and item.hostId is data.hostId)
        win.FillWindow data

      @socket.on 'clientPlacement', (placement) =>
        @clientPlacement = placement
        @serverPlacement = @screenPlacement[placement].reverse

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
    console.log 'Switch', placement

    switchedSave = @switched

    if @switched and placement?
      console.log 'Already Switched.'
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
    console.log 'Switch Win'
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

          @screenPlacement[k].client = new DistantScreen infos, socket

          @screenPlacement[k].client.on 'switch', =>
            @_Switch()

          @EnableSwitch k

          Log.Log 'New screen added: ', infos
          return

    socket.emit 'askScreenInfos'

module.exports = VirtualDisplay
