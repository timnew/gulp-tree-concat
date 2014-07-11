gulp-tree-concat
================

> A [Gulp](http://gulpjs.com/) processor to merge multiple javascript files into one with hierarchy

## Install

Install using [npm](https://npmjs.org/package/gulp-tree-concat).

    $ npm install gulp-tree-concat

## Usage

```javascript
var jade = require('gulp-jade')
  , treeConcat = require('gulp-tree-concat')

gulp.task('template', function () {
  gulp.src('client/templates/**/*.jade')
    .pipe(jade({client:true, compileDebug: false}}))    
    .pipe(treeConcat({
      output: 'template.js',
      namespace: 'Views.JadeTemplates',
      hierarchy: true,
      pathTemplate: treeConcat.path.relative('client/templates/')
    })
    .pipe(gulp.dest('public/assets'));
});
```

This compiles all of your jade template into a single file `template.js` as precompiled template,
defining `Views.JadeTemplates = { /* template fns */ }`.

Let's say we have views located at
- `client/app/views/item.jade` 
- `client/app/views/admin/user.jade`

Given the example's option as described before, those views
will now be accessible as precompiled [jade](http://jade-lang.com/) precompiled client template functions via

- `Views.JadeTemplates.item`
- `Views.JadeTemplates.admin.user`

(Please note that `gulp-tree-concat` only take cares to concat the compiled template, the jade template compiling is done by `gulp-jade`. And `gulp-tree-concat` doesn't have to be used in conjunction with `gulp-jade`. Any javascript files will do.)

## Options

### output
Type `String`
> The output file name

### namespace
Type `String`, default to `this.Templates`
> The object that holds the concated templates
> `gulp-tree-concat` respects your namespace, it appends new members to the namespace one by one instead of override the whole object with `=`. So multiple output file can be loaded without conflict.

### hierarchy
Type `Boolean`, default to `false`
> Indicate whether the hierarchy should be built.
> If `hierarchy` is set to `false` in the sample, the template `client/app/views/admin/user.jade` will be stored as `Views.JadeTemplates['admin/user']`.

### nameDivider
Type `String`, default to `/`
> The name divider to parse the hierarchy from the name of the template.
> Could change to `.` to build hierarchy from filename. 
> Since the value is used in `RegExp`, please escape it when necessary.
> Will be ignored if `hierarchy` is set to `false`

### pathTemplate
Type `[RegExp, String]`, default to `[/.*/g, '$&']`
> The template to extract template name from template full path. First one is the `RegExp` to match the full path, the second one is used to construct the template name.
> Follow the same rule as described in [`String.prototype.match`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace)

To simplify the usage, there are 2 template builder methods available:

#### `treeConcat.path.relative(baseFolder, extname = '.js')`

> Extract the the relative path based on `basedFolder`, extension name will be removed.

#### `treeConcat.path.filename(baseFolder, extname = '.js')`

> Extract the the plain file name, extension name will be removed.  

## License
MIT

