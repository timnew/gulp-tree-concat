require('coffee-script/register')

gulp = require('gulp')
del = require('del')
coffee = require('gulp-coffee')
bump = require('gulp-bump')
mocha = require('gulp-mocha')

argv = require('yargs')
  .alias('b', 'bump')
  .default('bump', 'patch')
  .describe('bump', 'bump [major|minor|patch|prerelease] version')  
  .argv

paths = 
  source:
    coffee: ['index.coffee']    
    spec: [['specs/*.spec.coffee', 'specs/**/*.spec.coffee'], {read: false}]
    manifest: ['./package.json']
  dest:
    root: './'
    js: ['index.js']

gulp.task 'clean', ->
  del.sync(paths.dest.js)

gulp.task 'coffee', ->
  gulp.src paths.source.coffee
    .pipe coffee()
    .pipe gulp.dest paths.dest.root

gulp.task 'mocha', ->
  gulp.src paths.source.spec[0], paths.source.spec[1]
    .pipe mocha({reporter: 'spec', growl: true})    

gulp.task 'build', ['clean', 'coffee', 'mocha']

gulp.task 'default', ['build']

gulp.task 'bump', ->  
  gulp.src paths.source.manifest
    .pipe bump { type: argv.bump }
    .pipe gulp.dest(paths.dest.root)  

gulp.task 'watch', ['mocha'], ->
  gulp.watch ['*.coffee', '**/*.coffee'], ['mocha']