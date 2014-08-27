@symbiose.directive 'symServer', [
	'config'
	(config) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/compiled/server.html'

			link: (scope, elem, attr) ->

				scope.config = config

				scope.saveConfig = ->
					config.Write()

		}
]

