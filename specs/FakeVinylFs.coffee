path = require('path')
File = require('vinyl')
Readable = require('readable-stream/readable')
Writable = require('readable-stream/writable')
through2 = require('through2')
Buffer = require('buffer').Buffer
_ = require('lodash')

path.batchJoin = (paths) ->
  path.join.apply(path, paths)

flattenFolder = (basepath, rootFolder) ->
  unless rootFolder?
    rootFolder = basepath
    basepath = []

  basepath = [basepath] if typeof basepath is 'string'

  result = []

  traversalFolder = (paths, folder) ->
    for name, content of folder
      paths.push name
      
      switch typeof content
        when 'string'          
          result.push new File            
            path: path.batchJoin(paths)
            contents: new Buffer(content)
        when 'function'
          result.push new File            
            path: path.batchJoin(paths)
            contents: new Buffer(content.toString())
        when 'object'
          traversalFolder paths, content

      paths.pop()

  traversalFolder basepath, rootFolder

  result

class FileStream extends Readable
  constructor: (@_dataArray) ->
    super
      objectMode: true,
      length: @_dataArray.length

  _read: ->
    file = @_dataArray.shift()
    
    if file?
      file = new File(file) unless file instanceof File

    @push file    

class FakeFolder extends Writable
  constructor: (@folder = {}) ->
    super
      objectMode: true

  _write: (file, enc, next) ->     
    if file.isBuffer()
      @folder[file.path] = file.contents.toString('utf8')
    else
      @folder[file.path] = file.contents

    next()

  onFinish: (cb) ->
    @on 'finish', =>
      cb(@folder)

FakeFs =   
  files: (files) ->
    new FileStream(files)

  folder: (basepath, folder) ->
    files = flattenFolder(basepath, folder)
    new FileStream(files)

  override: (values) ->
    through2 (file, enc, next) ->
      _.assign file, values

      next(null, file)

  toHash: (folder) ->
    new FakeFolder(folder)

exports = module.exports = FakeFs.folder

_.extend exports, FakeFs