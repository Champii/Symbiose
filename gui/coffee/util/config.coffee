fs = require 'fs'

class Config

	constructor: ->
		@path = '../config/'
		@filename = 'config'
		# fs.readdir '.', (err, filenames) ->
		# 	return console.error err if err?

		# 	console.log filenames

	Open: (mode) ->
		@fd = fs.openSync @path + @filename, mode

	Close: ->
		fs.closeSync @fd

	Create: ->
		@Open 'a'
		@Close()

	Parse: ->
		test = JSON.parse fs.readFileSync @path + @filename, encoding: 'UTF8'

		console.log 'parse', test
		for k, v of test
			@[k] = v

	Write: ->
		obj = {}
		for k, v of @ when k isnt 'path' and k isnt 'filename' and k isnt 'fd'
			obj[k] = v

		console.log 'write', obj
		fs.writeFileSync @path + @filename, JSON.stringify(obj), encoding: 'UTF8'

	Exists: ->
		fs.existsSync @path + @filename

	_DefaultConfig: ->
		mode: null

@config = new Config
