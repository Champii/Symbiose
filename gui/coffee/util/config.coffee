fs = require 'fs'

@symbiose.service 'config', [
	'$rootScope'
	($rootScope) ->

		@path = '../config/'
		@filename = 'config'
		@mode = null

		@Open = (mode) ->
			@fd = fs.openSync @path + @filename, mode

		@Close = ->
			fs.closeSync @fd

		@Create = ->
			@Open 'a'
			@Close()
			@Write()

		@Parse = ->
			test = JSON.parse fs.readFileSync @path + @filename, encoding: 'UTF8'

			console.log 'parse', test
			for k, v of test
				@[k] = v

		@Write = ->
			console.log @
			obj = {}
			for k, v of @ when k isnt 'path' and k isnt 'filename' and k isnt 'fd' and typeof v isnt 'function'
				obj[k] = v

			console.log 'write', obj
			fs.writeFileSync @path + @filename, JSON.stringify(obj), encoding: 'UTF8'

		@Exists = ->
			console.log 'lol'
			fs.existsSync @path + @filename

		if @Exists()
			console.log 'Exists !'
			@Parse()
		else
			console.log 'Create !'
			@Create()

		@SetMode = (@mode) ->

		@

]

