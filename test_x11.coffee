x11 = require 'x11'

Exposure = x11.eventMask.Exposure
PointerMotion = x11.eventMask.PointerMotion

x11.createClient (err, display) ->
  return console.error err if err?

  console.log display

  X = display.client
  root = display.screen[0].root
  wid = X.AllocID()

  X.CreateWindow wid, root,             # new window id, parent
                 0, 0, 100, 100,        # x, y, w, h
                 0, 0, 0, 0,            # border, depth, class, visual
                 { eventMask: Exposure|PointerMotion }

  X.MapWindow wid
  gc = X.AllocID()
  X.CreateGC gc, wid

  X.on 'event', (ev) ->
    console.log 'Event', ev
    X.PolyText8 wid, gc, 50, 50, ['Hello, Node.JS!'] if ev.type is 12

  X.on 'error', (e) ->
    console.error 'Error: ', e
