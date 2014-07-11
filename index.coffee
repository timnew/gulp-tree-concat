through = require('through2')
gutil = require('gulp-util')
PluginError = gutil.PluginError
File = gutil.File
Buffer = require('buffer').Buffer
_ = require('lodash')

newError = (content) ->
  new PluginError('gulp-tree-concat', content)

pathBuilder = 
  relative: (baseFolder, extname = '.js') ->      
    [new RegExp(".*#{baseFolder}(.*)\\#{extname}$",'g'), '$1']

  filename: (baseFolder, extname = '.js') ->
    [new RegExp(".*/(.*)\\#{extname}$",'g'), '$1']


module.exports = (opt) ->
  if typeof opt is 'string'
    opt = { output: opt }

  _.defaults opt, 
    pathTemplate: [/.*/g, '$&']
    namespace: 'this.Templates'
    hierarchy: false  
    nameDivider: '/'

  output = {}

  if opt.hierarchy
    putContent = (name, content) ->
      names = name.split(opt.nameDivider)
      
      last = names.pop()
      current = output

      current = current[currentName] ||= {} for currentName in names

      current[last] = content
    
    compileOutput = ->
      buffer = ''    

      travesal = (paths, obj) ->
        for own name, content of obj
          paths.push name
          switch typeof content
            when 'string'
              buffer += "#{paths.join('.')} = #{content};\n"
            when 'object'
              buffer += "#{paths.join('.')} ||= {};\n"
              travesal paths, content
          paths.pop()    

      travesal [opt.namespace], output

      output = {}

      buffer
  else
    putContent = (name, content) ->
      output[name] = content

    compileOutput = ->
      buffer = ''

      for own name, content of output
        buffer += "#{opt.namespace}[\"#{name}\"] = #{content};\n"

      output = {}
      buffer

  compileFile = (file, enc, next) ->
    return next newError 'Content is not loaded' if file.isNull()
    return next newError 'Streaming not supported' if  file.isStream()  
        
    content = file.contents.toString('utf8');
    name = file.path.replace(opt.pathTemplate[0], opt.pathTemplate[1])

    gutil.log "Load", gutil.colors.yellow(name), 'from', gutil.colors.magenta(file.path)

    putContent(name, content)

    next()

  flush = ->
    gutil.log 'Write concat result to', gutil.colors.magenta(opt.output)

    this.push new File
      path: opt.output
      contents: new Buffer(compileOutput())      

  through.obj compileFile, flush

module.exports.path = pathBuilder