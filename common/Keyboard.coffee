exec = require('child_process').exec
EventEmitter = require('events').EventEmitter

X = require '../common/X'
Log = require '../common/Log'

class Keyboard extends EventEmitter

  constructor: ->

    X.on 'event', (ev) =>
      if ev.name is 'KeyPress'
        @emit 'keyDown', ev.keycode
      if ev.name is 'KeyRelease'
        @emit 'keyUp', ev.keycode

  KeyDown: (code) ->
    X.KeyDown code

  KeyUp: (code) ->
    X.KeyUp code

module.exports = new Keyboard

