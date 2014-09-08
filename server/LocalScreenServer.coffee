mouse = require '../common/Mouse'
LocalScreen = require '../common/LocalScreen'

class LocalScreenServer extends LocalScreen

  constructor: ->
    super()

    @mouse.on 'moved', => @HasReachedEdge @mouse.pos

module.exports = LocalScreenServer
