var puppeteer = require("puppeteer");

exports.puppeteer = puppeteer;

exports._launch = function() {
  return puppeteer.launch();
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

exports._focus = function(page, selector) {
  return function() {
    return page.focus(selector);
  };
};

exports._type = function(page, content, options) {
  return function() {
    return page.type(content, options);
  };
};

exports._click = function(page, selector) {
  return function() {
    return page.click(selector);
  };
};

exports._waitForNavigation = function(page, options) {
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
