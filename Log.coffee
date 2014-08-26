###
0: no log
1: error log
2: warnings
3: log
###

class Log

	constructor: (@level) ->

	Error: ->
		console.error.apply console, arguments if @level >= 1

	Warning: ->
		console.log.apply console, arguments if @level >= 2

	Log: ->
		console.log.apply console, arguments if @level >= 3

	SetLevel: (@level) ->

module.exports = new Log 3

