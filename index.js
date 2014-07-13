(function() {
  var Buffer, File, PluginError, gutil, nameTemplates, newError, pathUtil, through, _,
    __hasProp = {}.hasOwnProperty;

  through = require('through2');

  gutil = require('gulp-util');

  PluginError = gutil.PluginError;

  File = gutil.File;

  Buffer = require('buffer').Buffer;

  pathUtil = require('path');

  _ = require('lodash');

  newError = function(content) {
    return new PluginError('gulp-tree-concat', content);
  };

  nameTemplates = {
    fullpath: function() {
      return function(file) {
        return file.path;
      };
    },
    filename: function(removeExtension) {
      if (removeExtension == null) {
        removeExtension = true;
      }
      if (typeof removeExtension === 'string') {
        return function(file) {
          return pathUtil.basename(file.path, removeExtension);
        };
      } else {
        if (removeExtension) {
          return function(file) {
            var extName;
            extName = pathUtil.extname(file.path);
            return pathUtil.basename(file.path, extName);
          };
        } else {
          return function(file) {
            return pathUtil.basename(file.path);
          };
        }
      }
    },
    relative: function(basePath, removeExtension) {
      var filenameTemplate;
      if (basePath == null) {
        basePath = '.';
      }
      if (removeExtension == null) {
        removeExtension = true;
      }
      filenameTemplate = nameTemplates.filename(removeExtension);
      return function(file) {
        var dirPath, fullBasePath, relativePath;
        fullBasePath = pathUtil.resolve(file.cwd, basePath);
        dirPath = pathUtil.dirname(file.path);
        relativePath = pathUtil.relative(fullBasePath, dirPath);
        return pathUtil.join(relativePath, filenameTemplate(file));
      };
    }
  };

  module.exports = function(opt) {
    var buildName, compileFile, compileOutput, flush, output, putContent, renderContent, renderStub;
    if (opt == null) {
      opt = {};
    }
    if (typeof opt === 'string') {
      opt = {
        output: opt
      };
    }
    _.defaults(opt, {
      pathTemplate: nameTemplates.fullpath(),
      namespace: 'this.Templates',
      hierarchy: false,
      nameDivider: '/'
    });
    output = {};
    buildName = function(basename, nameParts) {
      var part, result, _i, _len;
      if (nameParts == null) {
        return basename;
      }
      result = basename;
      for (_i = 0, _len = nameParts.length; _i < _len; _i++) {
        part = nameParts[_i];
        result += "[\"" + part + "\"]";
      }
      return result;
    };
    renderContent = function(basename, nameParts, content) {
      var name;
      name = buildName(basename, nameParts);
      return "" + name + " = " + content + ";\n";
    };
    renderStub = function(basename, nameParts) {
      var name;
      name = buildName(basename, nameParts);
      return "" + name + " = " + name + " != null ? " + name + " : {};\n";
    };
    if (opt.hierarchy) {
      putContent = function(name, content) {
        var current, currentName, last, names, _i, _len;
        names = name.split(opt.nameDivider);
        last = names.pop();
        current = output;
        for (_i = 0, _len = names.length; _i < _len; _i++) {
          currentName = names[_i];
          current = current[currentName] || (current[currentName] = {});
        }
        return current[last] = content;
      };
      compileOutput = function() {
        var buffer, travesal;
        buffer = renderStub(opt.namespace);
        travesal = function(paths, obj) {
          var content, name, _results;
          _results = [];
          for (name in obj) {
            if (!__hasProp.call(obj, name)) continue;
            content = obj[name];
            paths.push(name);
            switch (typeof content) {
              case 'string':
                buffer += renderContent(opt.namespace, paths, content);
                break;
              case 'object':
                buffer += renderStub(opt.namespace, paths);
                travesal(paths, content);
            }
            _results.push(paths.pop());
          }
          return _results;
        };
        travesal([], output);
        output = {};
        return buffer;
      };
    } else {
      putContent = function(name, content) {
        return output[name] = content;
      };
      compileOutput = function() {
        var buffer, content, name;
        buffer = renderStub(opt.namespace);
        for (name in output) {
          if (!__hasProp.call(output, name)) continue;
          content = output[name];
          buffer += renderContent(opt.namespace, [name], content);
        }
        output = {};
        return buffer;
      };
    }
    compileFile = function(file, enc, next) {
      var content, name;
      if (file.isNull()) {
        return next(newError('Content is not loaded'));
      }
      if (file.isStream()) {
        return next(newError('Streaming not supported'));
      }
      content = file.contents.toString('utf8');
      name = opt.pathTemplate(file);
      gutil.log("Load", gutil.colors.yellow(name), 'from', gutil.colors.magenta(file.path));
      putContent(name, content);
      return next();
    };
    flush = function() {
      gutil.log('Write concat result to', gutil.colors.magenta(opt.output));
      this.push(new File({
        path: opt.output,
        contents: new Buffer(compileOutput())
      }));
      return this.push(null);
    };
    return through.obj(compileFile, flush);
  };

  module.exports.nameTemplates = nameTemplates;

}).call(this);
