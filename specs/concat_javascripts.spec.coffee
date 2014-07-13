require('./spec_helper')

createFS = require('vinyl-fs-mock')
compileJs = require('./compileJs')

describe 'concat javascript', ->
  describe 'basic', ->
    fsData = ->
      'a.js': compileJs ->
        'a'
      'b.js': compileJs ->
        'b'
      'c.js': compileJs ->
        'c'
    
    it 'should concat content', (done) ->    
      fs = createFS fsData()      
      fs.createReadStream()      
        .pipe treeConcat 
          output: 'concat.js'
          pathTemplate: treeConcat.nameTemplates.filename()                 
        .pipe fs.createWriteStream()
        .onFinished done, (folder) ->
          concatedJs = folder['concat.js']        

          context = Sanbox.run concatedJs

          context.Templates.should.be.ok
          context.Templates.should.has.keys 'a','b','c'
          
          context.Templates.a().should.equal 'a'
          context.Templates.b().should.equal 'b'
          context.Templates.c().should.equal 'c'
              
  describe 'flat', ->  
    fsData = ->
      'f':
        'a.js': compileJs -> 'a'      
        'f1':
          'b.js': compileJs -> 'b'      
      'c.js': compileJs -> 'c'

    it 'should build path', (done) ->
      fs = createFS fsData()

      fs.createReadStream()
        .pipe treeConcat
          output: 'concat.js'        
          pathTemplate: treeConcat.nameTemplates.relative(process.cwd(), true)
        .pipe fs.createWriteStream()
        .onFinished done, (folder) ->
          concatedJs = folder['concat.js']

          context = Sanbox.run concatedJs

          context.Templates.should.be.ok          
          context.Templates.should.has.keys 'f/a', 'f/f1/b', 'c'
          context.Templates['f/a']().should.equal 'a'
          context.Templates['f/f1/b']().should.equal 'b'
          context.Templates['c']().should.equal 'c'
          
  describe 'hierarchy', ->
    fsData = ->
      'f':
        'a.js': compileJs -> 'a'      
        'f1':
          'b.js': compileJs -> 'b'      
      'c.js': compileJs -> 'c'

    it 'should build path', (done) ->
      fs = createFS fsData()
      fs.createReadStream()
        .pipe treeConcat
          output: 'concat.js'     
          hierarchy: true   
          pathTemplate: treeConcat.nameTemplates.relative(process.cwd(), true)
        .pipe fs.createWriteStream()
        .onFinished done, (folder) ->
          concatedJs = folder['concat.js']
           
          context = Sanbox.run concatedJs

          context.Templates.should.be.ok
          context.Templates.should.has.keys 'f', 'c'
          context.Templates.f.should.has.keys 'a', 'f1'
          context.Templates.f.f1.should.has.keys 'b'
          
          context.Templates.f.a().should.equal 'a'
          context.Templates.f.f1.b().should.equal 'b'
          context.Templates.c().should.equal 'c'