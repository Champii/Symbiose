// Generated by CoffeeScript 1.7.1
var server;

server = null;

this.symbiose.directive('symServer', [
  '$rootScope', 'config', 'trayMenu', 'windowMenuService', function($rootScope, config, trayMenu, windowMenuService) {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'views/compiled/server.html',
      link: function(scope, elem, attr) {
        scope.config = config;
        scope.started = false;
        $rootScope.$on('config_reset', function(e, config) {
          return scope.$apply(function() {
            return scope.config = config;
          });
        });
        $rootScope.$on('start', function() {
          return scope.$apply(function() {
            return scope.startServer();
          });
        });
        $rootScope.$on('stop', function() {
          return scope.$apply(function() {
            return scope.stopServer();
          });
        });
        scope.saveConfig = function() {
          return config.Write();
        };
        scope.startServer = function() {
          var Server;
          scope.saveConfig();
          Server = require('../server/compiled/Server');
          server = new Server;
          scope.started = true;
          trayMenu.startButton.enabled = false;
          return trayMenu.stopButton.enabled = true;
        };
        return scope.stopServer = function() {
          server.Stop();
          server = null;
          scope.started = false;
          trayMenu.startButton.enabled = true;
          return trayMenu.stopButton.enabled = false;
        };
      }
    };
  }
]);
