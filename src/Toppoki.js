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
