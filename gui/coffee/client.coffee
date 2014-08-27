client = null

@symbiose.directive 'symClient', [
	'$rootScope'
	'config'
	($rootScope, config) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/compiled/client.html'

			link: (scope, elem, attr) ->

				scope.config = config
				scope.started = false

				$rootScope.$on 'config_reset', (e, config) ->
					scope.$apply ->
						scope.config = config

				scope.saveConfig = ->
					config.Write()

				scope.startClient = ->
					scope.saveConfig()

					Client = require '../client/compiled/Client'

					client = new Client

					scope.started = true

				scope.stopClient = ->
					client.Stop()

					client = null

					scope.started = false

		}
]

