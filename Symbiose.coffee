exec = require('child_process').exec

class Symbiose

	constructor: ->
		@Run()

	Run: ->
		exec './common/nodewebkit/nw ./gui'

app = new Symbiose
