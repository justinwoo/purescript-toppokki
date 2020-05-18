var puppeteer = require("puppeteer");

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

exports._unsafeEvaluateOnNewDocument = function(string, page) {
  return function() {
     return page.evaluateOnNewDocument(string);
  }
}

exports._unsafeEvaluateStringFunction = function(string, page) {
  return function() {
    return page.evaluate(string);
  };
};

exports._unsafePageEval = function(selector, fnStr, page) {
  return function() {
    return page.$eval(selector, eval(fnStr));
  };
};

exports._unsafePageEvalAll = function(selector, fnStr, page) {
  return function() {
    return page.$$eval(selector, eval(fnStr));
  };
};

exports._keyboardDown = function(string, options, page) {
  return function() {
    return page.keyboard.down(string, options);
  };
};

exports._keyboardPress = function(key, options, page) {
  return function() {
    return page.keyboard.press(key, options);
  };
};

exports._keyboardSendCharacter = function(char, page) {
  return function() {
    return page.keyboard.sendCharacter(char);
  };
};

exports._keyboardType = function(text, options, page) {
  return function() {
    return page.keyboard.type(text, options);
  };
};

exports._keyboardUp = function(string, options, page) {
  return function() {
    return page.keyboard.up(string, options);
  };
};

exports._setUserAgent = function(string, page) {
  return function() {
    return page.setUserAgent(string);
  };
};

exports._bringToFront = function(page) {
  return function() {
    return page.bringToFront();
  };
};
