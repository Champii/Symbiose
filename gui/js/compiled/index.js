// Generated by CoffeeScript 1.7.1
var gui, menu, quitButton, tray, visible, win, winFileMenu, winMenu;

gui = require('nw.gui');

visible = true;

win = gui.Window.get();

win.on('close', function() {
  this.hide();
  return visible = false;
});

tray = new gui.Tray({
  title: 'Tray',
  icon: 'gui/img/logo.jpg'
});

tray.on('click', function(a, b) {
  visible = !visible;
  if (visible) {
    win.show();
  }
  if (!visible) {
    return win.hide();
  }
});

menu = new gui.Menu();

quitButton = new gui.MenuItem({
  label: 'Quit',
  click: function() {
    return win.close(1);
  }
});

menu.append(quitButton);

tray.menu = menu;

winMenu = new gui.Menu({
  type: 'menubar'
});

winFileMenu = new gui.MenuItem({
  label: 'File'
});

winFileMenu.submenu = new gui.Menu;

winFileMenu.submenu.append(new gui.MenuItem({
  label: 'Reset',
  click: function() {
    return conf.Reset();
  }
}));

winFileMenu.submenu.append(new gui.MenuItem({
  label: 'Quit',
  click: function() {
    return win.close(1);
  }
}));

winMenu.append(winFileMenu);

win.menu = winMenu;

this.symbiose = angular.module('symbiose', ['ngRoute']);
