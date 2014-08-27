// Generated by CoffeeScript 1.7.1
var client;

client = null;

this.symbiose.directive('symClient', [
  '$rootScope', 'config', function($rootScope, config) {
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
        scope.saveConfig = function() {
          return config.Write();
        };
        scope.startClient = function() {
          var Client;
          scope.saveConfig();
          Client = require('../client/compiled/Client');
          client = new Client;
          return scope.started = true;
        };
        return scope.stopClient = function() {
          client.Stop();
          client = null;
          return scope.started = false;
        };
      }
    };
  }
]);
