exec = require('child_process').exec

class MouseWriter

	constructor: (@socket) ->
		if @socket?
			@socket.on 'mousemove', @MoveRelativeTo

	_Xte: (order, args) ->
		exec "xte -x :0.0 '" + order + " " + args + "'"

	MoveTo: (pos) ->
		@_Xte 'mousemove', pos.x + ' ' + pos.y

	MoveRelativeTo: (pos) ->
		@_Xte 'mousermove', pos.xDelta + ' ' + pos.yDelta

module.exports = MouseWriter


# var app = require('express').createServer(),
# 	io = require('socket.io').listen(app),
# 	exec = require('child_process').exec;//,
# //	mdns = require('mdns');

# app.listen(8080);
# console.log('Running on port 8080');
# //mdns.createAdvertisement('websocket', 3080).start();

# app.get('/', function (req, res) {
# 	res.sendfile(__dirname + '/app.html');
# });

# io.configure(undefined, function(){
# 	io.set('log level', 3);
# });

# function xte(c, s) {
# 	exec("xte -x :0.0 '" + c + " " + s + "'");
# }

# function click(n) {
# 	xte('mouseclick', n);
# }

# io.sockets.on('connection', function(socket) {
# 	socket.on('mousemove', function(d) {
# 		xte('mousermove', d);
# 	});

# 	socket.on('click', function() {
# 		click(1);
# 	});

# 	socket.on('mousedown', function(button) {
# 		if (button === undefined) button = 1;
# 		else button = button + 1;

# 		xte('mousedown', button);
# 	});

# 	socket.on('mouseup', function(button) {
# 		if (button === undefined) button = 1;
# 		else button = button + 1;

# 		xte('mouseup', button);
# 	});

# 	socket.on('rightclick', function() {
# 		console.log('right click');
# 		click(3);
# 	});

# 	socket.on('middleclick', function() {
# 		click(2);
# 	});

# 	socket.on('scrollup', function() {
# 		click(4);
# 	});

# 	socket.on('scrolldown', function() {
# 		click(5);
# 	});

# 	socket.on('keydown', function(key) {
# 		xte('keydown', key)
# 	});

# 	socket.on('keyup', function(key) {
# 		xte('keyup', key)
# 	});
# });
