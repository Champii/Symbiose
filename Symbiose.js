// Generated by CoffeeScript 1.7.1
(function() {
  var Client, Server, Symbiose, app, exec;

  exec = require('child_process').exec;

  Server = require('./server/compiled/Server');

  Client = require('./client/compiled/Client');

  Symbiose = (function() {
    function Symbiose() {}

    Symbiose.prototype.Run = function() {
      return exec('../nodewebkit/nw .');
    };

    Symbiose.prototype.RunServerCli = function() {
      return new Server;
    };

    Symbiose.prototype.RunClientCli = function() {
      return new Client;
    };

    return Symbiose;

  })();

  app = new Symbiose;

  if (process.argv[2] === '-q' && process.argv[3] === '-s') {
    app.RunServerCli();
  } else if (process.argv[2] === '-q' && process.argv[3] === '-c') {
    app.RunClientCli();
  } else {
    app.Run();
  }

}).call(this);
