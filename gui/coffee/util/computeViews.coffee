fs = require 'fs'
jade = require 'jade'
async = require 'async'

getViews = (done) ->
  fs.readdir './views', (err, filenames) ->
    return done err if err?

    appendPath = (filename, done) ->
      done null, {path: './views/' + filename, name: filename}

    async.map filenames, appendPath, done

compileViews = (files, done) ->

  jadeComp = (file, done) ->
    fn = jade.compileFile file.path
    done null, {content: fn(), name: file.name.split('.')[0] + '-tpl'}

  async.map files, jadeComp, done

appendViews = (files, done) ->

  $(document).ready ->
    appendFile = (file, done) ->
      template = '<script type="text/ng-template" id="' + file.name + '">' + file.content + '</script>'

      $('#content').append template

    async.each files, appendFile
    done()

getViews (err, files) ->
  return console.error err if err?

  compileViews files, (err, compFiles) ->
    return console.error err if err?

    appendViews compFiles, (err) ->
      return console.error err if err?
