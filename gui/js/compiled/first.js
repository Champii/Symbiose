// Generated by CoffeeScript 1.7.1
var config;

config = this.config;

this.symbiose.directive('symFirst', [
  function() {
    return {
      restrict: 'E',
      replace: false,
      templateUrl: 'views/compiled/first.html',
      link: function(scope, elem, attr) {
        scope.visible = !config.Exists();
        console.log(config, config.Exists());
        return scope.applyConfig = function(mode) {
          config.Create();
          config.mode = mode;
          config.Write();
          return scope.visible = false;
        };
      }
    };
  }
]);
