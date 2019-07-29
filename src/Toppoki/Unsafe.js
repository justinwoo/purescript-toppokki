/* global require exports */
var path = require("path");
var browserify = null;
var UglifyJS = null;

try {
  browserify = require('browserify');
  UglifyJS = require("uglify-js");
} catch (e) {

}

var Readable = require("stream").Readable;

// Extract all variable names starting with capital letters.
// Throw an error if there are free variables.
function extractDefinitions (code) {
  var globals = new Set();

  function visitor(node, descend) {
    if (node instanceof UglifyJS.AST_Toplevel) {
      node.figure_out_scope();
    }

    if (node instanceof UglifyJS.AST_Symbol) {
      if (/[A-Z]/.test(node.name[0])) {
        if (!globals.has(node.name)) {
          globals.add(node.name);
        }
      } else {
        if (node.undeclared()) {
          throw new Error("Toppokki internal error: are you trying to use " +
                          "point-free style in a callback function?  (see " +
                          "docs/unsafe.md)");
        }
      }
    }
  }

  var walker = new UglifyJS.TreeWalker(visitor);
  UglifyJS.parse('(' + code + ')').walk(walker);
  return Array.from(globals);
}

function wrapTopLevel(code) {
  return new Function(
    'arg',

    'var TOPLEVEL_TOPPOKI_FUNCTION;\n' + code +
    ';\nreturn TOPLEVEL_TOPPOKI_FUNCTION(arg)();'
  );
}

// `wrapTopLevelString`, unlike `wrapTopLevel`, returns a concrete value,
// rather than a function.
function wrapTopLevelString(code) {
  // The function is supposed to accept a `unit` value.
  //
  // ```
  // newtype InjectedAff r = InjectedAff (Unit -> Promise r)
  // ```
  //
  // But since the newtype internals are not exposed, and the value is not used,
  // it is safe to pass nothing.

  return '(function(){\n  var TOPLEVEL_TOPPOKI_FUNCTION;\n' +
    code + ';\n  return TOPLEVEL_TOPPOKI_FUNCTION()();\n})()';
}

exports._jsReflect = function(func) {
  if (browserify === null || UglifyJS === null) {
    throw new Error("Toppokki internal error: to use `unsafe*` functions, run `npm install uglify-js@2 browserify`");
  }

  return function(){
    return new Promise(function (resolve, reject) {
      var code = func.toString();
      var globals = extractDefinitions(code);

      var readable = new Readable();
      readable.push('(function () {\n  ');
      globals.forEach(function(mod) {
        readable.push(
          'var ' + mod + ' = require("./' +
            mod.replace(/_/g, '.') + '");\n'
        );
      });

      readable.push('\n  TOPLEVEL_TOPPOKI_FUNCTION = ');
      readable.push(code);
      readable.push('\n})()');
      readable.push(null);
      var b = browserify(readable, {
        basedir: path.join(__dirname, '..'),
        ignoreMissing: true,
        detectGlobals: false,
        // Not required - we do not use packages
        browserField: false,
      });
      var str = b.bundle(function (err, buff) {
        if (err !== null) {
          reject(err);
        }
        resolve(buff.toString());
      });
    });
  };
};

exports._queryEval = function(selector, code, queryable) {
  return function() {
    return queryable.$eval(selector, wrapTopLevel(code));
  };
};

exports._queryEvalMany = function(selector, code, queryable) {
  return function() {
    return queryable.$$eval(selector, wrapTopLevel(code));
  };
};

exports._evaluate = function(code, ctx) {
  return function() {
    return ctx.evaluate(wrapTopLevelString(code));
  };
};
