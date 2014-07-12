require('./spec_helper')

fakeFs = require('./FakeVinylFs')

describe 'concat javascript', ->
  describe 'basic', ->
    createFs = ->
      fakeFs
        'a.js': ->
          'a'
        'b.js': ->
          'b'
        'c.js': ->
          'c'

    it 'should concat content', (done) ->    
      createFs()
        .pipe treeConcat 
          output: 'concat.js'
          pathTemplate: treeConcat.nameTemplates.filename()        
        .pipe fakeFs.toHash()
        .onFinish (folder) ->
          concatedJs = folder['concat.js']        

          try
            context = Sanbox.run concatedJs

            context.Templates.should.be.ok
            context.Templates.should.has.keys 'a','b','c'
            
            context.Templates.a().should.equal 'a'
            context.Templates.b().should.equal 'b'
            context.Templates.c().should.equal 'c'

            done()
          catch ex
            done(ex)
              
  describe 'flat', ->  
    createFs = ->
      fakeFs
        '/f/a.js': -> 'a'      
        '/f/f1/b.js': -> 'b'
        '/c.js': -> 'c'

    it 'should build path', (done) ->
      createFs()
        .pipe treeConcat
          output: 'concat.js'        
          pathTemplate: treeConcat.nameTemplates.relative('/', true)
        .pipe fakeFs.toHash()
        .onFinish (folder) ->
          concatedJs = folder['concat.js']

          try
            context = Sanbox.run concatedJs

            context.Templates.should.be.ok
            context.Templates.should.has.keys 'f/a', 'f/f1/b', 'c'
            context.Templates['f/a']().should.equal 'a'
            context.Templates['f/f1/b']().should.equal 'b'
            context.Templates['c']().should.equal 'c'

            done()
          catch ex
            done(ex)
          
  describe 'hierarchy', ->
    createFs = ->
      fakeFs
        '/f/a.js': -> 'a'      
        '/f/f1/b.js': -> 'b'
        '/c.js': -> 'c'

    it 'should build path', (done) ->
      createFs()
        .pipe treeConcat
          output: 'concat.js'     
          hierarchy: true   
          pathTemplate: treeConcat.nameTemplates.relative('/', true)
        .pipe fakeFs.toHash()
        .onFinish (folder) ->
          concatedJs = folder['concat.js']

          try
            context = Sanbox.run concatedJs

            context.Templates.should.be.ok
            context.Templates.should.has.keys 'f', 'c'
            context.Templates.f.should.has.keys 'a', 'f1'
            context.Templates.f.f1.should.has.keys 'b'
            
            context.Templates.f.a().should.equal 'a'
            context.Templates.f.f1.b().should.equal 'b'
            context.Templates.c().should.equal 'c'

            done()
          catch ex
            done(ex)
