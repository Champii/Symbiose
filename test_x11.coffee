x11 = require 'x11'

Exposure = x11.eventMask.Exposure
PointerMotion = x11.eventMask.PointerMotion
EnterWindow = x11.eventMask.EnterWindow
LeaveWindow = x11.eventMask.LeaveWindow
FocusChange = x11.eventMask.FocusChange
PropertyChange = x11.eventMask.PropertyChange
StructureNotify = x11.eventMask.StructureNotify
ButtonPress = x11.eventMask.ButtonPress

ShowEventsMasks = (mask) ->
  console.log 'MASQUES : '
  for k, v of x11.eventMask
    if mask & v
      console.log 'Event mask : ', k

x11.createClient (err, display) ->
  return console.error err if err?

  # console.log 'Display', err, display

  X = display.client
  root = display.screen[0].root

  # X.GetInputFocus (err, data) ->
  #   console.log 'InputFocus : ', err, data
  #   X.ChangeWindowAttributes data.focus,
  #     eventMask: Exposure|PointerMotion|EnterWindow|ButtonPress
  #     doNotPropagateMask: false

  # X.ConfigureWindow root,
  #   height: 100
  #   width: 100

  setInterval ->
    X.QueryPointer root, (err, fields) ->
      console.log err, fields
  , 50

  X.QueryTree root, (err, tree) ->
    tree.children.forEach (wid) ->
      X.GetWindowAttributes wid, (err, attrs) ->
        # console.log 'Wid', wid
        # console.log 'Attrs', err, attrs
        # ShowEventsMasks attrs.myEventMasks

        newAttrs = {}
        newAttrs.eventMask = Exposure|PointerMotion|StructureNotify

        X.ChangeWindowAttributes wid
          eventMask: Exposure|StructureNotify

      # X.MapWindow wid


  # wid = X.AllocID()


  # X.CreateWindow wid, root,             # new window id, parent
  #                0, 0, 100, 100,        # x, y, w, h
  #                0, 0, 0, 0,            # border, depth, class, visual
  #                { eventMask: EnterWindow|LeaveWindow|FocusChange }

  # X.MapWindow root
  # gc = X.AllocID()
  # X.CreateGC gc, wid

  X.on 'event', (ev) ->
    console.log 'Event', ev
    # if ev.name = 'EnterNotify'
    #   X.SetInputFocus ev.wid, 1, (err, res) ->
    #     console.log 'Set input', err, res
    #   X.GrabPointer ev.wid, false, {eventMask: Exposure|PointerMotion|EnterWindow}, (err, res) ->
    #     console.log 'RES', err, res
    # X.PolyText8 wid, gc, 50, 50, ['Hello, Node.JS!'] if ev.type is 12

  X.on 'error', (e) ->
    console.error 'Error: ', e

