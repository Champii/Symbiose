gui = require('nw.gui');

# Angular
@symbiose = angular.module 'symbiose', ['ngRoute']

# Window
@symbiose.service 'windowService', [
	'$rootScope'
	($rootScope) ->
		@visible = true

		@win = gui.Window.get()

		@win.on 'close', () =>
		  @win.hide()
		  @visible = false

		@
]

# Tray
@symbiose.service 'trayService', [
	'$rootScope'
	'windowService'
	($rootScope, windowService) ->
		@tray = new gui.Tray  {title: 'Tray', icon: 'gui/img/logo.jpg'}

		@tray.on 'click', (a, b) ->
			windowService.visible = !windowService.visible

			windowService.win.show() if windowService.visible
			windowService.win.hide() if not windowService.visible

		@
]
# Tray Menu
@symbiose.service 'trayMenu', [
	'$rootScope'
	'windowService'
	'trayService'
	($rootScope, windowService, trayService) ->
		@menu = new gui.Menu()

		@quitButton = new gui.MenuItem
			label: 'Quit'
			click: ->
				windowService.win.close 1

		@startButton = new gui.MenuItem
			label: 'Start'
			click: ->
				$rootScope.$emit 'start'

		@stopButton = new gui.MenuItem
			label: 'Stop'
			click: ->
				$rootScope.$emit 'stop'
			enabled: false

		@menu.append @startButton
		@menu.append @stopButton
		@menu.append new gui.MenuItem type: 'separator'
		@menu.append @quitButton

		trayService.tray.menu = @menu

		@
]

# Window Menu
@symbiose.service 'windowMenuService', [
	'config'
	'windowService'
	(config, windowService) ->

		@winMenu = new gui.Menu type: 'menubar'

		winFileMenu = new gui.MenuItem label: 'File'

		winFileMenu.submenu = new gui.Menu

		winFileMenu.submenu.append new gui.MenuItem {label: 'Reset', click: -> config.Reset()}

		winFileMenu.submenu.append new gui.MenuItem {label: 'Quit', click: -> windowService.win.close 1}

		@winMenu.append winFileMenu

		windowService.win.menu = @winMenu

		@
]
