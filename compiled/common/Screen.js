// Generated by CoffeeScript 1.7.1
var EventEmitter, Log, Screen, Window, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('underscore');

EventEmitter = require('events').EventEmitter;

Log = require('./Log');

Window = require('./Window');

Screen = (function(_super) {
  __extends(Screen, _super);

  function Screen() {
    this.windows = {};
  }

  Screen.prototype.NewWindow = function(blob) {
    var win;
    win = new Window(blob);
    this.AddWindow(win);
    return win;
  };

  Screen.prototype.AddWindow = function(win) {
    if (this.HasWindow(win)) {
      return;
    }
    return this.windows[win.id] = win;
  };

  Screen.prototype.DelWindow = function(win) {
    return this.windows = _(this.windows).reject(function(item) {
      if (item != null) {
        return item.wid === win.wid;
      } else {
        return false;
      }
    });
  };

  Screen.prototype.GetWindow = function(wid) {
    return _(this.windows).find((function(_this) {
      return function(item) {
        return (item != null) && item.wid === wid;
      };
    })(this));
  };

  Screen.prototype.HasWindow = function(win) {
    return this.GetWindow(win.wid) != null;
  };

  Screen.prototype.HasReachedEdge = function(obj) {
    if (obj.x <= 1) {
      return 'Left';
    } else if (obj.y <= 1) {
      return 'Top';
    } else if (obj.x >= this.size.width - 2) {
      return 'Right';
    } else if (obj.y >= this.size.height - 2) {
      return 'Bottom';
    }
  };

  Screen.prototype.IsFullScreen = function(win) {
    if (!win.x && win.width === this.size.width && win.height > this.size.height - 100) {
      return true;
    }
    return false;
  };

  return Screen;

})(EventEmitter);

module.exports = Screen;
