_ = require 'underscore'

X = require '../common/X'
Log = require '../common/Log'
LocalScreenClient = require './LocalScreenClient'
Window = require '../common/Window'
VirtualDisplay = require '../common/VirtualDisplay'


class VirtualDisplayClient extends VirtualDisplay

  constructor: (@socket) ->
    super()

    @mainScreen = new LocalScreenClient

    @socket.on 'newWindow', (data) =>
      win = _(@mainScreen.windows).find((item) => item? and item.hostId is data.hostId)
      if not win?
        # console.log 'New window !', data
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
      # console.log 'Window content'
      win = _(@mainScreen.windows).find((item) => item? and item.hostId is data.hostId)
      win.FillWindow data

    @socket.on 'clientPlacement', (placement) =>
      @clientPlacement = placement
      @serverPlacement = @screenPlacement[placement].reverse

    X.on 'event', (ev) =>
      if ev.name is 'ConfigureNotify'
        if @mainScreen.HasWindow ev
          return

        @mainScreen.NewWindow ev

module.exports = VirtualDisplayClient
