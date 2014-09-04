// Generated by CoffeeScript 1.7.1
var Config, Server, VirtualDisplay, X, bus, config, exports;

bus = require('../common/Bus');

X = require('../common/X');

VirtualDisplay = require('../common/VirtualDisplay');

Config = require('../gui/js/util/config');

config = new Config;

Server = (function() {
  function Server() {
    var io;
    io = require('socket.io')(config.port);
    this.socket = null;
    X.Init((function(_this) {
      return function() {
        _this.virtDisplay = new VirtualDisplay;
        return io.sockets.on('connection', function(socket) {
          _this.socket = socket;
          return _this.virtDisplay.AddScreen(_this.socket);
        });
      };
    })(this));
  }

  Server.prototype.Stop = function() {
    this.virtDisplay.Destroy();
    this.socket = null;
    return this.virtDisplay = null;
  };

  return Server;

})();

module.exports = exports = Server;
