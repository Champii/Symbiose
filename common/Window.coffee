_ = require 'underscore'
EventEmitter = require('events').EventEmitter

X = require './X'
Log = require './Log'

validAttrs =
  wid: 0
  x: 0
  y: 0
  width: 100
  height: 100
  borderWidth: 1
  depth: 0
  type: 1
  visuals: 0
  attributes:
    eventMask: X.defaultEventMask
  visible: false
  distant: false
  hostId: 0

nextId = 0

class Window extends EventEmitter

  constructor: (attrs) ->
    @id = nextId++
    @Deserialize attrs

    # console.log 'NewWindow'
    if not @wid
      res = X.CreateWindow @
      @wid = res[0]
      @_cgid = res[1]

    # else
    #   @GetWindowAttributes()

    if @visible
      @Show()

    if @distant and attrs.image
      @FillWindow attrs.image
      @Show()

    @Init()

  Init: ->
    eventsHandlers =
     ConfigureNotify: (ev) => @HandleConfigure ev
     Expose:          (ev) => @HandleExpose ev
     MapNotify:       (ev) => @HandleMap ev
     DamageNotify:    (ev) => @HandleDamage ev

    X.on 'event', (ev) =>
      if (ev.wid is @wid and not @distant) or not ev.wid?
        eventsHandlers[ev.name](ev) if eventsHandlers[ev.name]?


  Deserialize: (attrs) ->
    for k, v of attrs when validAttrs[k]?
      @[k] = v

    for k, v of validAttrs
      if not @[k]?
        @[k] = v

  Serialize: ->
    hostId: if @hostId then @hostId else @id
    width: @width
    height: @height
    distant: true
    visible: true

  # GetWindowAttributes: ->
  #   X.X.GetWindowAttributes @wid, (err, attrs) =>
  #     return Log.Error err if err?

  #     console.log 'Deserialize: ', attrs
  #     @Deserialize attrs

  Show: ->
    @visible = true
    X.MapWindow @wid

  Hide: ->
    @visible = false
    X.UnmapWindow @wid

  Move: (pos) ->
    X.X.ConfigureWindow @wid, pos

  Resize: (size) ->
    X.X.ConfigureWindow @wid, size

  HandleConfigure: (ev) ->
    if ev.x isnt @x or ev.y isnt @y
      @x = ev.x
      @y = ev.y
      @emit 'moved'

    if ev.width isnt @width or ev.height isnt @height
      @width = ev.width
      @height = ev.height
      @emit 'resized'

  HandleExpose: (ev) ->
    # console.log 'Expose !', @, ev

  HandleMap: (ev) ->
    X.X.FreePixmap @offPixmap
    @GetOffPixmap()

  HandleDamage: (ev) ->
    @SendTo ev.area, @socket if @socket?

  FillWindow: (image) ->
    X.FillWindow @, image

  SendTo: (region, socket) ->
    if not socket?
      socket = region
      region =
        x: 0
        y: 0
        w: @width
        h: @height

    thus = @
    pixmap = _(thus).extend
      wid: @offPixmap

    X.GetWindowImage pixmap, region, (err, image) =>
      return Log.Error 'GetWindowImage', err if err?

      socket.emit 'windowContent', _(@Serialize()).extend
        image: image
        region: region

  ActivateDamage: (@socket) ->

    @damageId = X.X.AllocID()

    X.damage.Create @damageId, @offPixmap, X.damage.ReportLevel.RawRectangles

  DesactivateDamage: ->
    X.damage.Destroy @damageId

  GetOffPixmap: ->
    # console.log 'GetOffPixmap'

    @offPixmap = X.X.AllocID()

    X.composite.NameWindowPixmap @wid, @offPixmap, (err) => Log.Error 'Composite: NameWindowPixmap', err if err?

  Destroy: ->
    X.X.DestroyWindow @wid

module.exports = Window
