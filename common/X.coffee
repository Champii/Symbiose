_ = require 'underscore'
x11 = require 'x11'
EventEmitter = require('events').EventEmitter

Log = require './Log'

Exposure = x11.eventMask.Exposure
PointerMotion = x11.eventMask.PointerMotion
ButtonMotion = x11.eventMask.ButtonMotion
Button1Motion = x11.eventMask.Button1Motion
ButtonPress = x11.eventMask.ButtonPress
ButtonRelease = x11.eventMask.ButtonRelease
StructureNotify = x11.eventMask.StructureNotify
SubstructureNotify = x11.eventMask.SubstructureNotify

class X extends EventEmitter

  constructor: ->
    @grabed = false
    @windowId = 0
    @windows = []

    @defaultEventMask = Exposure|PointerMotion|StructureNotify|SubstructureNotify

  Init: (done) ->
    x11.createClient (err, display) =>
      return Log.Error err if err?

      @display = display

      @X = @display.client
      @screen = @display.screen[0]
      @root = @screen.root

      @InitEventTree @root

      @X.on 'event', (ev) =>
        @emit 'event', ev

        if ev.name is 'CreateNotify'
          @InitEventTree ev.parent

      @X.on 'error', (e) =>
        Log.Error 'Main error: ', e

      @X.require 'composite', (err, comp) =>
        return console.error err if err?

        @composite = comp

      @X.require 'damage', (err, damage) =>
        return console.error err if err?

        @damage = damage

        # @composite.GetOverlayWindow @root, (err, wid) =>
        #   console.log 'GetOverlayWindow', err, wid

      done()

  InitEventTree: (root) ->
    @X.QueryTree root, (err, tree) =>
      return Log.Error err if err?

      tree.children.forEach (wid) =>
        @X.ChangeWindowAttributes wid,
          eventMask: @defaultEventMask
        , (err) => console.error 'Error InitEventTree: ', wid, err

        @InitEventTree wid

  CreateBlankCursor: ->
    if not @cursorId?
      cursorSourceId = @X.AllocID()

      @X.CreatePixmap cursorSourceId,
                      @captureWid,
                      1,
                      1,
                      1

      gc = @X.AllocID()
      @X.CreateGC gc, cursorSourceId

      @X.PutImage 1,
                  cursorSourceId,
                  gc,
                  1,
                  1,
                  0,
                  0,
                  0,
                  1,
                  0

      color =
        R: 0
        G: 0
        B: 0

      @cursorId = @X.AllocID()

      @X.CreateCursor @cursorId,
                      cursorSourceId,
                      0,
                      color,
                      color,
                      0,
                      0

    return @cursorId

  CreateWindow: (win) ->
    wid = @X.AllocID()
    console.log 'CreateWindow', win
    @X.CreateWindow wid,
                    @root,
                    win.x,
                    win.y,
                    win.width,
                    win.height,
                    win.borderWidth, # border width
                    win.depth, # depth
                    win.type, # InputOutput
                    win.visuals, # visuals
                    win.attributes,
                    (err) ->
                      Log.Error 'CreateWindow', err

    gc = @X.AllocID()
    @X.CreateGC gc, wid, (err) => Log.Error 'CreateGC', err

    return [wid, gc]

  MapWindow: (wid) ->
    @X.MapWindow wid, (err) => Log.Error 'Map', err

  UnmapWindow: (wid) ->
    @X.UnmapWindow wid

  CreateCaptureWindow: ->
    @captureWid = @X.AllocID()
    @X.CreateWindow @captureWid,
                    @root,
                    0,
                    0,
                    @display.screen[0].pixel_width,
                    @display.screen[0].pixel_height,
                    0,
                    0,
                    1,
                    0,
                      {eventMask: PointerMotion|ButtonPress|ButtonRelease},
                    (err) => Log.Error 'CaptureWin', err if err?

    @X.ChangeWindowAttributes @captureWid,
      cursor: @CreateBlankCursor()

    @X.MapWindow @captureWid
    return @captureWid


  DestroyCaptureWindow: ->
    @X.DestroyWindow @captureWid
    @captureWid = null

  MovePointer: (pos) ->
    target = @root
    # if @grabed
    #   target = @captureWid

    @X.WarpPointer  0,
                    target,
                    0,
                    0,
                    0,
                    0,
                    pos.x,
                    pos.y

  Grab: ->
    @X.GrabPointer  @captureWid,
                    false,
                    {eventMask: PointerMotion|ButtonPress},
                    undefined,
                    undefined,
                    @captureWid,
                    (err, data) -> console.log 'Grab', err, data
    @grabed = true

  Ungrab: ->
    @X.UngrabPointer()
    @grabed = false

  GetWindowImage: (win, region, done) ->
    if not done? and region?
      done = region

    if not region?
      region =
        x: 0
        y: 0
        w: win.width
        h: win.height

    @X.GetImage 2,
                win.wid,
                region.x,
                region.y,
                region.w,
                region.h,
                0xffffffff,
                done

  FillWindow: (win, image) ->
    # console.log 'FillWindow', image

    @X.PutImage 2,
                win.wid,
                win._cgid,
                image.region.w,
                image.region.h,
                image.region.x,
                image.region.y,
                0, # left paded
                24, # depth
                image.image.data,
                (err, lol) -> console.log 'PutImage', err


module.exports = new X
