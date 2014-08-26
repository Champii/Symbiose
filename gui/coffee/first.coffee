@symbiose.directive 'symFirst', [
	() ->

		return {

			restrict: 'E'

			replace: false

			templateUrl: 'views/compiled/first.html'

			link: (scope, elem, attr) ->

				console.log 'lol'
				scope.lol = 'coucou'

		}
]

