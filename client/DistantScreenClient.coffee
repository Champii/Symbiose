DistantScreen = require '../common/DistantScreen'

class DistantScreenClient extends DistantScreen

  constructor: (infos, socket) ->
    super infos, socket

module.exports = DistantScreenClient
