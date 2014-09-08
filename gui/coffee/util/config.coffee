fs = require 'fs'

rootScope = null
conf = null

class Config

  constructor:  ->
    @path = './config/'
    @filename = 'config'
    @mode = null
    if @Exists()
      @Parse()
    else
      @Create()

    if rootScope?
      rootScope.$on 'config_reset', (e, config) =>
        console.log '1', @
        @Parse()
        console.log '2', @

  Open: (mode) ->
    @fd = fs.openSync @path + @filename, mode

  Close: ->
    fs.closeSync @fd

  Create: ->
    @Open 'a'
    @Close()
    @Write()

  Parse: ->
    test = JSON.parse fs.readFileSync @path + @filename, encoding: 'UTF8'

    for k, v of test
      @[k] = v

  Write: ->
    obj = {}
    for k, v of @ when k isnt 'path' and k isnt 'filename' and k isnt 'fd' and typeof v isnt 'function'
      obj[k] = v

    fs.writeFileSync @path + @filename, JSON.stringify(obj), encoding: 'UTF8'

  Exists: ->
    fs.existsSync @path + @filename

  Reset: ->
    for k, v of @ when k isnt 'path' and k isnt 'filename' and k isnt 'fd' and typeof v isnt 'function'
      delete @[k]
    @mode = null
    @Write()

    if rootScope?
      rootScope.$emit 'config_reset', @

config = ($rootScope) ->
  rootScope = $rootScope
  conf = new Config
  for k, v of conf
    @[k] = v

  @

if @symbiose?
  @symbiose.service 'config', ['$rootScope', config]

if module?
  module.exports = Config
