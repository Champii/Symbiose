client = null

@symbiose.directive 'symClient', [
	'$rootScope'
	'config'
	'trayMenu'
	'windowMenuService'
	($rootScope, config, trayMenu, windowMenuService) ->

		return {

			restrict: 'E'

			replace: true

			templateUrl: 'views/client.html'

			link: (scope, elem, attr) ->

				scope.config = config
				scope.started = false

				$rootScope.$on 'config_reset', (e, config) ->
					scope.$apply ->
						scope.config = config

				$rootScope.$on 'start', ->
					scope.$apply ->
						scope.startClient()
				$rootScope.$on 'stop', ->
					scope.$apply ->
						scope.stopClient()

				scope.saveConfig = ->
					config.Write()

				scope.startClient = ->
					scope.saveConfig()

					Client = require '../client/Client'

					client = new Client

					scope.started = true
					trayMenu.startButton.enabled = false
					trayMenu.stopButton.enabled = true

				scope.stopClient = ->
					client.Stop()

					client = null

					scope.started = false

					trayMenu.startButton.enabled = true
					trayMenu.stopButton.enabled = false

		}
]

