@symbiose.directive 'symClient', [
	'config'
	(config) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/compiled/client.html'

			link: (scope, elem, attr) ->

				scope.config = config

				scope.saveConfig = ->
					config.Write()

		}
]

