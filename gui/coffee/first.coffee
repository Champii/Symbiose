@symbiose.directive 'symFirst', [
	'config'
	(config) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/compiled/first.html'

			link: (scope, elem, attr) ->

				scope.applyConfig = (mode) ->
					console.log 'Mode', mode
					config.SetMode mode
					# config.mode = mode
					config.Write()

		}
]

