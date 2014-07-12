through = require('through2')
gutil = require('gulp-util')
PluginError = gutil.PluginError
File = gutil.File
Buffer = require('buffer').Buffer
pathUtil = require('path')
_ = require('lodash')

newError = (content) ->
  new PluginError('gulp-tree-concat', content)

nameTemplates = 
  fullpath: ->
    (file) ->
      file.path

  filename: (removeExtension = true) -> 
    if typeof removeExtension is 'string'
      (file) ->          
        pathUtil.basename(file.path, removeExtension)  
    else    
      if removeExtension      
        (file) ->
          extName = pathUtil.extname(file.path)
          pathUtil.basename(file.path, extName)
      else
        (file) ->
          pathUtil.basename(file.path)
    
  relative: (basePath = '.', removeExtension = true) ->          
    filenameTemplate = nameTemplates.filename(removeExtension)    
    
    (file) ->      
      fullBasePath = pathUtil.resolve(file.cwd, basePath)
      dirPath = pathUtil.dirname(file.path)
      relativePath = pathUtil.relative(fullBasePath, dirPath)      
      pathUtil.join(relativePath, filenameTemplate(file))

module.exports = (opt = {}) ->
  if typeof opt is 'string'
    opt = { output: opt }

  _.defaults opt, 
    pathTemplate: nameTemplates.fullpath()
    namespace: 'this.Templates'
    hierarchy: false  
    nameDivider: '/'

  output = {}

  buildName = (basename, nameParts) ->        
    return basename unless nameParts?

    result = basename

    for part in nameParts
      result += "[\"#{part}\"]"

    result

  renderContent = (basename, nameParts, content) ->
    name = buildName(basename, nameParts)
    
    "#{name} = #{content};\n"

  renderStub = (basename, nameParts) ->
    name = buildName(basename, nameParts)
    
    "#{name} = #{name} != null ? #{name} : {};\n"

  if opt.hierarchy
    putContent = (name, content) ->
      names = name.split(opt.nameDivider)
      
      last = names.pop()
      current = output

      current = current[currentName] ||= {} for currentName in names

      current[last] = content

    compileOutput = ->
      buffer = renderStub opt.namespace        

      travesal = (paths, obj) ->
        for own name, content of obj
          paths.push name
          switch typeof content
            when 'string'              
              buffer += renderContent(opt.namespace, paths, content)
            when 'object'
              buffer += renderStub(opt.namespace, paths)              
              travesal paths, content
          paths.pop()    

      travesal [], output

      output = {}

      buffer
  else
    putContent = (name, content) ->
      output[name] = content

    compileOutput = ->
      buffer = renderStub(opt.namespace)   

      for own name, content of output        
        buffer += renderContent(opt.namespace, [name], content)              

      output = {}

      buffer

  compileFile = (file, enc, next) ->
    return next newError 'Content is not loaded' if file.isNull()
    return next newError 'Streaming not supported' if  file.isStream()  
        
    content = file.contents.toString('utf8');
    name = opt.pathTemplate(file)

    gutil.log "Load", gutil.colors.yellow(name), 'from', gutil.colors.magenta(file.path)

    putContent(name, content)

    next()

  flush = ->
    gutil.log 'Write concat result to', gutil.colors.magenta(opt.output)

    @push new File
      path: opt.output
      contents: new Buffer(compileOutput())      

    @push null

  through.obj compileFile, flush

module.exports.nameTemplates = nameTemplates