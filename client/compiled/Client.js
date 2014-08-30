// Generated by CoffeeScript 1.7.1
var Client, Config, Log, MouseWriter, config, exports, io, x11;

x11 = require('x11');

io = require('socket.io-client');

Log = require('../../common/compiled/Log');

MouseWriter = require('../../common/compiled/MouseWriter');

Config = require('../../gui/js/compiled/util/config');

config = new Config;

Client = (function() {
  function Client() {
    Log.SetLevel(2);
    x11.createClient((function(_this) {
      return function(err, display) {
        if (err != null) {
          return Log.Error(err);
        }
        _this.screen = {
          width: display.screen[0].pixel_width,
          height: display.screen[0].pixel_height
        };
        return Log.Warning(_this.screen);
      };
    })(this));
    this.socket = io('http://' + config.host + ':' + config.port);
    this.socket.on('askScreenInfos', (function(_this) {
      return function() {
        return _this.socket.emit('screenInfos', _this.screen);
      };
    })(this));
    this.mouseWrite = new MouseWriter;
    this.socket.on('initialCursorPos', (function(_this) {
      return function(pos) {
        Log.Log('initial pos', pos);
        return _this.mouseWrite.MoveTo(pos);
      };
    })(this));
    this.socket.on('mousePos', (function(_this) {
      return function(pos) {
        Log.Log('mouse pos', pos);
        return _this.mouseWrite.MoveTo(pos);
      };
    })(this));
    this.socket.on('buttonDown', (function(_this) {
      return function(i) {
        return _this.mouseWrite.ButtonDown(i);
      };
    })(this));
    this.socket.on('buttonUp', (function(_this) {
      return function(i) {
        return _this.mouseWrite.ButtonUp(i);
      };
    })(this));
  }

  Client.prototype.Stop = function() {
    return this.socket = null;
  };

  return Client;

})();

module.exports = exports = Client;
