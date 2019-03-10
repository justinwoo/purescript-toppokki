var path = require("path");
var puppeteer = require("puppeteer");
var browserify = require('browserify');
var UglifyJS = require("uglify-js");
var Readable = require("stream").Readable;

// Extract all variable names starting from capital letter
function extractDefinitions (code) {
  var globals = new Set();

  function visitor(node, descend) {
    if (node instanceof UglifyJS.AST_Symbol) {
      if (/[A-Z]/.test(node.name[0]) && !globals.has(node.name)) {
        globals.add(node.name);
      }
    }
  }

  var walker = new UglifyJS.TreeWalker(visitor);
  UglifyJS.parse(code).walk(walker);
  return Array.from(globals);
}

function wrapTopLevel(code) {
  return new Function(
    'arg',

    'var TOPLEVEL_TOPPOKI_FUNCTION;\n' + code +
    ';\nreturn TOPLEVEL_TOPPOKI_FUNCTION(arg);'
  );
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
  var code = '(' + func.toString() + ')';
  var globals = extractDefinitions(code);

  return function(){
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

    return new Promise(function (resolve, reject) {
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

exports._pageWaitForSelector = function(selector, options, page) {
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
