mouse = require './Mouse'
keyboard = require './Keyboard'
Log = require './Log'

class VirtualDisplay

  constructor: ->
    @mouse = mouse
    @keyboard = keyboard

    @screenPlacement =
      Top:
        reverse: 'Bottom'
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


module.exports = VirtualDisplay
