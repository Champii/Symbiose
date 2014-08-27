server = null

@symbiose.directive 'symServer', [
	'$rootScope'
	'config'
	($rootScope, config) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/compiled/server.html'

			link: (scope, elem, attr) ->

				scope.config = config
				scope.started = false

				$rootScope.$on 'config_reset', (e, config) ->
					scope.$apply ->
						scope.config = config

				scope.saveConfig = ->
					config.Write()

				scope.startServer = ->

					scope.saveConfig()

					Server = require '../server/compiled/Server'

					server = new Server

					scope.started = true

				scope.stopServer = ->
					server.Stop()

					server = null

					scope.started = false

		}
]

