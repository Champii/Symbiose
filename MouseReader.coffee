###
 * Read Linux mouse(s) in node.js
 * Author: Marc Loehe (marcloehe@gmail.com)
 * Rewriten in CoffeeScript by Florian Greiner (florian.greiner.pro@gmail.com)
 *
 * Adapted from Tim Caswell's nice solution to read a linux joystick
 * http://nodebits.org/linux-joystick
 * https://github.com/nodebits/linux-joystick
###

fs = require 'fs'
EventEmitter = require('events').EventEmitter

parse = (buffer) ->
  event =
    leftBtn:    (buffer[0] & 1  ) > 0
    rightBtn:   (buffer[0] & 2  ) > 0
    middleBtn:  (buffer[0] & 4  ) > 0
    xSign:      (buffer[0] & 16 ) > 0
    ySign:      (buffer[0] & 32 ) > 0
    xOverflow:  (buffer[0] & 64 ) > 0
    yOverflow:  (buffer[0] & 128) > 0
    xDelta:      buffer.readInt8(1)
    yDelta:      buffer.readInt8(2)

  if (event.leftBtn || event.rightBtn || event.middleBtn)
    event.type = 'button'
  else
    event.type = 'moved'

  return event

class MouseReader extends EventEmitter

  constructor: (mouseid) ->
    @Wrap 'OnOpen'
    @Wrap 'OnRead'
    @dev = if typeof(mouseid) is 'number' then 'mouse' + mouseid else 'mice'
    @buf = new Buffer 3
    fs.open('/dev/input/' + @dev, 'r', @OnOpen);

  Wrap: (name) ->
    fn = @[name]
    @[name] = (err) =>
      return @emit 'error', err if err?
      return fn.apply(@, Array.prototype.slice.call(arguments, 1))

  OnOpen: (fd) ->
    @fd = fd
    @StartRead()

  StartRead: ->
    fs.read @fd, @buf, 0, 3, null, @OnRead

  OnRead: (bytesRead) ->
    event = parse @buf
    event.dev = @dev
    @emit event.type, event
    @StartRead() if @fd

  Close: (callback) ->
    fs.close @fd, -> console.log @
    @fd = undefined


module.exports = MouseReader
# mouse = new Mouse
# mouse.on 'button', console.log
# mouse.on 'moved', console.log

