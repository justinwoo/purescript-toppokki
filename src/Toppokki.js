var path = require("path");
var puppeteer = require("puppeteer");
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

exports.puppeteer = puppeteer;

exports._launch = function(options) {
  return function() {
    return puppeteer.launch(options);
  };
};

exports._newPage = function(browser) {
  return function() {
    return browser.newPage();
  };
};

exports._query = function(selector, queryable) {
  return function() {
    return queryable.$(selector);
  };
};

exports._queryMany = function(selector, queryable) {
  return function() {
    return queryable.$$(selector);
  };
};


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

exports._goto = function(url, page) {
  return function() {
    return page.goto(url);
  };
};

exports._close = function(browser) {
  return function() {
    return browser.close();
  };
};

exports._content = function(page) {
  return function() {
    return page.content();
  };
};

exports._content = function(page) {
  return function() {
    return page.content();
  };
};

exports._title = function(page) {
  return function () {
    return page.title();
  };
};

exports._setUserAgent = function(userAgent, page) {
  return function () {
    return page.setUserAgent(userAgent);
  };
};

exports._setViewport = function(viewport, page) {
  return function () {
    return page.setViewport(viewport);
  };
};

exports._screenshot = function(options, page) {
  return function() {
    return page.screenshot(options);
  };
};

exports._pdf = function(options, page) {
  return function() {
    return page.pdf(options);
  };
};

exports._on = function(event, callback, page) {
  return page.on(event, callback);
};

exports._waitForSelector = function(selector, options, page) {
  return function() {
    return page.waitForSelector(selector, options);
  };
};

exports._focus = function(selector, page) {
  return function() {
    return page.focus(selector);
  };
};

exports._type = function(selector, content, options, page) {
  return function() {
    return page.type(selector, content, options);
  };
};

exports._click = function(selector, page) {
  return function() {
    return page.click(selector);
  };
};

exports._waitForNavigation = function(options, page) {
  return function() {
    return page.waitForNavigation(options);
  };
};

exports._getLocationHref = function(page) {
  return function() {
    return page.evaluate(function() {
      return window.location.href;
    });
  };
};

exports._unsafeEvaluateStringFunction = function(string, page) {
  return function() {
    return page.evaluate(string);
  };
};
