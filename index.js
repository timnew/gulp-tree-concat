(function() {
  var Buffer, File, PluginError, gutil, newError, pathTemplates, through, _,
    __hasProp = {}.hasOwnProperty;

  through = require('through2');

  gutil = require('gulp-util');

  PluginError = gutil.PluginError;

  File = gutil.File;

  Buffer = require('buffer').Buffer;

  _ = require('lodash');

  newError = function(content) {
    return new PluginError('gulp-tree-concat', content);
  };

  pathTemplates = {
    none: function() {
      return function(path) {
        return path;
      };
    },
    relative: function(baseFolder, extname) {
      (function(path) {
        return path.replace(opt.pathTemplate[0], '$1');
      });
      return [new RegExp(".*" + baseFolder + "(.*)\\" + extname + "$", 'g'), '$1'];
    },
    filename: function(baseFolder, extname) {
      return [new RegExp(".*/(.*)\\" + extname + "$", 'g'), '$1'];
    }
  };

  module.exports = function(opt) {
    var compileFile, compileOutput, flush, output, putContent;
    if (typeof opt === 'string') {
      opt = {
        output: opt
      };
    }
    _.defaults(opt, {
      pathTemplate: pathTemplates.none,
      namespace: 'this.Templates',
      hierarchy: false,
      nameDivider: '/'
    });
    output = {};
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
        buffer = '';
        travesal = function(paths, obj) {
          var content, name, _results;
          _results = [];
          for (name in obj) {
            if (!__hasProp.call(obj, name)) continue;
            content = obj[name];
            paths.push(name);
            switch (typeof content) {
              case 'string':
                buffer += "" + (paths.join('.')) + " = " + content + ";\n";
                break;
              case 'object':
                buffer += "" + (paths.join('.')) + " ||= {};\n";
                travesal(paths, content);
            }
            _results.push(paths.pop());
          }
          return _results;
        };
        travesal([opt.namespace], output);
        output = {};
        return buffer;
      };
    } else {
      putContent = function(name, content) {
        return output[name] = content;
      };
      compileOutput = function() {
        var buffer, content, name;
        buffer = '';
        for (name in output) {
          if (!__hasProp.call(output, name)) continue;
          content = output[name];
          buffer += "" + opt.namespace + "[\"" + name + "\"] = " + content + ";\n";
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
      name = opt.pathTemplate(file.path);
      gutil.log("Load", gutil.colors.yellow(name), 'from', gutil.colors.magenta(file.path));
      putContent(name, content);
      return next();
    };
    flush = function() {
      gutil.log('Write concat result to', gutil.colors.magenta(opt.output));
      return this.push(new File({
        path: opt.output,
        contents: new Buffer(compileOutput())
      }));
    };
    return through.obj(compileFile, flush);
  };

  module.exports.path = pathTemplates;

}).call(this);
