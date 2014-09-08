// Generated by CoffeeScript 1.7.1
var LocalScreen, LocalScreenServer, mouse,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

mouse = require('../common/Mouse');

LocalScreen = require('../common/LocalScreen');

LocalScreenServer = (function(_super) {
  __extends(LocalScreenServer, _super);

  function LocalScreenServer() {
    LocalScreenServer.__super__.constructor.call(this);
    this.mouse.on('moved', (function(_this) {
      return function() {
        return _this.HasReachedEdge(_this.mouse.pos);
      };
    })(this));
  }

  return LocalScreenServer;

})(LocalScreen);

module.exports = LocalScreenServer;
