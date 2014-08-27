// Generated by CoffeeScript 1.7.1
var client;

client = null;

this.symbiose.directive('symClient', [
  '$rootScope', 'config', 'trayMenu', 'windowMenuService', function($rootScope, config, trayMenu, windowMenuService) {
    return {
      restrict: 'E',
      replace: true,
      templateUrl: 'views/compiled/client.html',
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
            return scope.startClient();
          });
        });
        $rootScope.$on('stop', function() {
          return scope.$apply(function() {
            return scope.stopClient();
          });
        });
        scope.saveConfig = function() {
          return config.Write();
        };
        scope.startClient = function() {
          var Client;
          scope.saveConfig();
          Client = require('../client/compiled/Client');
          client = new Client;
          scope.started = true;
          trayMenu.startButton.enabled = false;
          return trayMenu.stopButton.enabled = true;
        };
        return scope.stopClient = function() {
          client.Stop();
          client = null;
          scope.started = false;
          trayMenu.startButton.enabled = true;
          return trayMenu.stopButton.enabled = false;
        };
      }
    };
  }
]);
