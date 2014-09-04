// Generated by CoffeeScript 1.7.1
var DistantScreen, EventEmitter, Log, Window, X, mouse,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

X = require('./X');

Log = require('./Log');

mouse = require('../common/Mouse');

Window = require('./Window');

DistantScreen = (function(_super) {
  __extends(DistantScreen, _super);

  function DistantScreen(infos, socket) {
    this.socket = socket;
    this.windows = [];
    this.size = {
      width: infos.width,
      height: infos.height
    };
    this.name = infos.name;
    this.screenPosition = infos.position;
    this.pos = {
      x: 0,
      y: 0
    };
    this.socket.emit('clientPosition', this.screenPosition);
  }

  DistantScreen.prototype.MovePointer = function(pos) {
    this.pos = pos;
    this._ContentPointer();
    return this.socket.emit('mousePos', this.pos);
  };

  DistantScreen.prototype.MovePointerRelative = function(delta) {
    this.pos.x = this.pos.x + delta.x;
    this.pos.y = this.pos.y + delta.y;
    this._ContentPointer();
    this.socket.emit('mousePos', this.pos);
    return this.HasReachedEdge();
  };

  DistantScreen.prototype._ContentPointer = function() {
    if (this.pos.x < 0) {
      this.pos.x = 0;
    }
    if (this.pos.x >= this.size.width) {
      this.pos.x = this.size.width;
    }
    if (this.pos.y < 0) {
      this.pos.y = 0;
    }
    if (this.pos.y >= this.size.height) {
      return this.pos.y = this.size.height;
    }
  };

  DistantScreen.prototype.HasReachedEdge = function() {
    if (this.pos.x <= 0 && this.screenPosition === 'Right') {
      return this.emit('switch');
    } else if (this.pos.y <= 0 && this.screenPosition === 'Bottom') {
      return this.emit('switch');
    } else if (this.pos.x >= this.size.width && this.screenPosition === 'Left') {
      return this.emit('switch');
    } else if (this.pos.y >= this.size.height && this.screenPosition === 'Top') {
      return this.emit('switch');
    }
  };

  DistantScreen.prototype.AddWindow = function(win) {
    return this.windows.push(win);
  };

  DistantScreen.prototype.DelWindow = function(win) {
    return this.windows = _(this.windows).reject(function(item) {
      return item.id === win.id;
    });
  };

  return DistantScreen;

})(EventEmitter);

module.exports = DistantScreen;
