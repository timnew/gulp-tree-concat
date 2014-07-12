gulp-tree-concat [![NPM version][npm-image]][npm-url] [![Build Status][ci-image]][ci-url] [![Dependency Status][depstat-image]][depstat-url]
================

> A [Gulp](http://gulpjs.com/) processor to merge multiple javascript files into one with hierarchy

## Install

Install using [npm][npm-url].

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
      nameTemplate: treeConcat.nameTemplates.relative('client/templates/')
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

### Sample Output

** TODO **

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

### nameTemplate
Type `function(File)`, `(File) -> node name` Mapping, default to `treeConcat.path.none`
> The function to build the name for a file, usually the name is exctract from file name. But also could be extract from `contents` if necessary

Several predefined builder are included:

### `treeConcat.nameTemplates.fullpath()`

> Extract the file full path as template name
> `/folder/file.js` will be mapped to `/folder/file.js`

#### `treeConcat.nameTemplates.filename(removeExtension = true)`

> Extract the file name as template name, extension name can be removed
> `/folder/file.js` will be mapped to `file`

**Parameters**

* **removeExtension**  controls how the extension is removed
  * **true** the extensions are removed
  * **false** the exensions are reserved
  * **'.js'** only the extensions matched are removed

#### `treeConcat.nameTemplates.relative(baseFolder, removeExtension = true)`

> Extract the the relative path based on `basedFolder`, extension name can be removed
> `/folder/subfolder/file.js` will be mapped to `subfolder/file`

**Parameters**

* **baseFolder** the relative path that you want to remove from name

* **removeExtension**  controls how the extension is removed
  * **true** the extensions are removed
  * **false** the exensions are reserved
  * **'.js'** only the extensions matched are removed


## License
MIT

[![NPM downloads][npm-downloads]][npm-url]

[npm-url]: https://npmjs.org/package/gulp-tree-concat
[npm-image]: http://img.shields.io/npm/v/gulp-tree-concat.svg?style=flat
[npm-downloads]: http://img.shields.io/npm/dm/gulp-tree-concat.svg?style=flat

[ci-url]: https://drone.io/github.com/timnew/gulp-tree-concat/latest
[ci-image]: https://drone.io/github.com/timnew/gulp-tree-concat/status.png

[depstat-url]: https://gemnasium.com/timnew/gulp-tree-concat
[depstat-image]: http://img.shields.io/gemnasium/timnew/gulp-tree-concat.svg?style=flat
