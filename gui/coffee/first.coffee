config = @config

@symbiose.directive 'symFirst', [
	() ->

		return {

			restrict: 'E'

			replace: false

			templateUrl: 'views/compiled/first.html'

			link: (scope, elem, attr) ->

				scope.visible = !config.Exists()
				console.log config, config.Exists()
				scope.applyConfig = (mode) ->
					config.Create()
					config.mode = mode
					config.Write()
					scope.visible = false

		}
]

