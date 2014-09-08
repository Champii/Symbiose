// Generated by CoffeeScript 1.7.1
var EventEmitter, Keyboard, Log, X, exec,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

exec = require('child_process').exec;

EventEmitter = require('events').EventEmitter;

X = require('../common/X');

Log = require('../common/Log');

Keyboard = (function(_super) {
  __extends(Keyboard, _super);

  function Keyboard() {
    X.on('event', (function(_this) {
      return function(ev) {
        if (ev.name === 'KeyPress') {
          _this.emit('keyDown', ev.keycode);
        }
        if (ev.name === 'KeyRelease') {
          return _this.emit('keyUp', ev.keycode);
        }
      };
    })(this));
  }

  Keyboard.prototype.KeyDown = function(code) {
    return X.KeyDown(code);
  };

  Keyboard.prototype.KeyUp = function(code) {
    return X.KeyUp(code);
  };

  return Keyboard;

})(EventEmitter);

module.exports = new Keyboard;