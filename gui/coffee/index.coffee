gui = require('nw.gui');

# Window
visible = true

win = gui.Window.get()

win.on 'close', () ->
  this.hide()
  visible = false

# Tray
tray = new gui.Tray  {title: 'Tray', icon: 'gui/img/logo.jpg'}

tray.on 'click', (a, b) ->
	visible = !visible

	win.show() if visible
	win.hide() if not visible

# Tray Menu
menu = new gui.Menu()

quitButton = new gui.MenuItem
	label: 'Quit'
	click: ->
		win.close 1

menu.append quitButton

tray.menu = menu

# Window Menu
winMenu = new gui.Menu type: 'menubar'

winFileMenu = new gui.MenuItem label: 'File'

winFileMenu.submenu = new gui.Menu

winFileMenu.submenu.append new gui.MenuItem {label: 'Reset', click: -> conf.Reset()}

winFileMenu.submenu.append new gui.MenuItem {label: 'Quit', click: -> win.close 1}

winMenu.append winFileMenu

win.menu = winMenu

# Angular
@symbiose = angular.module 'symbiose', ['ngRoute']
