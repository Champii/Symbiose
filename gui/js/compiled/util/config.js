// Generated by CoffeeScript 1.7.1
var fs;

fs = require('fs');

this.symbiose.service('config', [
  '$rootScope', function($rootScope) {
    this.path = '../config/';
    this.filename = 'config';
    this.mode = null;
    this.Open = function(mode) {
      return this.fd = fs.openSync(this.path + this.filename, mode);
    };
    this.Close = function() {
      return fs.closeSync(this.fd);
    };
    this.Create = function() {
      this.Open('a');
      this.Close();
      return this.Write();
    };
    this.Parse = function() {
      var k, test, v, _results;
      test = JSON.parse(fs.readFileSync(this.path + this.filename, {
        encoding: 'UTF8'
      }));
      console.log('parse', test);
      _results = [];
      for (k in test) {
        v = test[k];
        _results.push(this[k] = v);
      }
      return _results;
    };
    this.Write = function() {
      var k, obj, v;
      console.log(this);
      obj = {};
      for (k in this) {
        v = this[k];
        if (k !== 'path' && k !== 'filename' && k !== 'fd' && typeof v !== 'function') {
          obj[k] = v;
        }
      }
      console.log('write', obj);
      return fs.writeFileSync(this.path + this.filename, JSON.stringify(obj), {
        encoding: 'UTF8'
      });
    };
    this.Exists = function() {
      console.log('lol');
      return fs.existsSync(this.path + this.filename);
    };
    if (this.Exists()) {
      console.log('Exists !');
      this.Parse();
    } else {
      console.log('Create !');
      this.Create();
    }
    this.SetMode = function(mode) {
      this.mode = mode;
    };
    return this;
  }
]);
