mouse = require '../common/Mouse'
DistantScreen = require '../common/DistantScreen'

class DistantScreenServer extends DistantScreen

  constructor: (infos, socket) ->
    super infos, socket

    @socket.emit 'clientPosition', @placement

module.exports = DistantScreenServer
