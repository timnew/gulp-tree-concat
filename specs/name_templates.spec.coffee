require('./spec_helper')
File = require('vinyl')
_ = require('lodash')

describe 'name template', ->
  
  nameTemplates = treeConcat.nameTemplates

  file = (overrides) ->
    overrides = { path: overrides } if typeof overrides is 'string'

    _.defaults overrides,
      cwd: '/'
      base: '/'
      contents: null
    
    new File overrides      
  
  describe 'fullpath', ->
    it 'should pass through', ->
      template = nameTemplates.fullpath()
      template(file('/sample_path/sample_file.js')).should.equal '/sample_path/sample_file.js'

  describe 'filename', ->
    it 'should extract filename without ext by default', ->
      template = nameTemplates.filename()

      template(file('/sample_path/sample_file.js')).should.equal 'sample_file'

    it 'should extract filename with extension', ->
      template = nameTemplates.filename(false)

      template(file('/sample_path/sample_file.js')).should.equal 'sample_file.js'

    it 'should extract filename without extension', ->
      template = nameTemplates.filename(true)

      template(file('/sample_path/sample_file.js')).should.equal 'sample_file'

    describe 'remove specific file extension', ->
      template = nameTemplates.filename('.js')

      it 'should remove if match', ->
        template(file('/sample_path/sample_file.js')).should.equal 'sample_file'

      it 'should not remove if not match', ->
        template(file('/sample_path/sample_file.jade')).should.equal 'sample_file.jade'

  describe 'relative', ->
    it 'should extract relative', ->
      template = nameTemplates.relative('sample_path')

      template(file('/sample_path/sub_folder/sample_file.js')).should.equal 'sub_folder/sample_file'

    it 'should handle tail /', ->
      template = nameTemplates.relative('/sample_path/')

      template(file('/sample_path/sub_folder/sample_file.js')).should.equal 'sub_folder/sample_file'

    it 'should handle relative base path', ->
      template = nameTemplates.relative('src')            

      template(file(path: '/project/src/sub_folder/sample_file.js', cwd: '/project')).should.equal 'sub_folder/sample_file'
