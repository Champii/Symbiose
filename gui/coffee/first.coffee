@symbiose.directive 'symFirst', [
	'$rootScope'
	'config'
	($rootScope, config) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/compiled/first.html'

			link: (scope, elem, attr) ->

				scope.config = config

				scope.applyConfig = (mode) ->
					config.Write()

				$rootScope.$on 'config_reset', (e, config) ->
					scope.$apply ->
						scope.config = config

		}
]

