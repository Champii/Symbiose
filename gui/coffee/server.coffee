server = null

@symbiose.directive 'symServer', [
	'$rootScope'
	'config'
	'trayMenu'
	'windowMenuService'
	($rootScope, config, trayMenu, windowMenuService) ->

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

				$rootScope.$on 'start', ->
					scope.$apply ->
						scope.startServer()
				$rootScope.$on 'stop', ->
					scope.$apply ->
						scope.stopServer()


				scope.saveConfig = ->
					config.Write()

				scope.startServer = ->
					scope.saveConfig()

					Server = require '../server/compiled/Server'

					server = new Server

					scope.started = true
					trayMenu.startButton.enabled = false
					trayMenu.stopButton.enabled = true

				scope.stopServer = ->
					server.Stop()

					server = null

					scope.started = false
					trayMenu.startButton.enabled = true
					trayMenu.stopButton.enabled = false

		}
]

